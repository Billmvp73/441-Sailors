from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import math
from django.shortcuts import render
from google.oauth2 import id_token
from google.auth.transport import requests

import hashlib, time

def getgames(request, city_info):
    if request.method != 'GET':
        return HttpResponse(status=404)
    # city = city_info.split('+')[0]
    # latitude = float(city_info.split('+')[1])
    # longitude = float(city_info.split('+')[2])

    
    response = {}
    if city_info == "null":
        response['games'] = []
        return JsonResponse(response)

    cursor = connection.cursor()
    cursor.execute('SELECT username, gamename, description, tag, location, cast(gid as varchar), time, puzzles FROM games WHERE city = %s ORDER BY time DESC;', (city_info,))
    rows = cursor.fetchall()

    response['games'] = rows
    return JsonResponse(response)

@csrf_exempt
def postgames(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    cursor = connection.cursor()

    token = json_data['token']
    cursor.execute('SELECT username, expiration FROM users WHERE token = %s;', (token,))

    row = cursor.fetchone()
    now = time.time()
    if row is None or now > row[1]:
        # return an error if there is no chatter with that ID
        return HttpResponse(status=401) # 401 Unauthorized


    gamename = json_data['gamename']
    description = json_data['description']
    tag = json_data['tag']
    tag = tag.replace(" ", "")
    tag = tag.replace(",", ", ")
    location = json_data['location']
    try:
        city = location.split(',')[2].split('"')[1]
    except:
        city = "null"
    puzzles = json_data['puzzles']
    cursor.execute('INSERT INTO games (username, gamename, description, tag, location, puzzles, city) VALUES '
                   '(%s, %s, %s,%s, %s, %s, %s);', (row[0], gamename, description, tag, location, puzzles, city))
    return JsonResponse({})


@csrf_exempt
def adduser(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    clientID = json_data['clientID']   # the front end app's OAuth 2.0 Client ID
    idToken = json_data['idToken']     # user's OpenID ID Token, a JSon Web Token (JWT)

    now = time.time()                  # secs since epoch (1/1/70, 00:00:00 UTC)

    try:
        # Collect user info from the Google idToken, verify_oauth2_token checks
        # the integrity of idToken and throws a "ValueError" if idToken or
        # clientID is corrupted or if user has been disconnected from Google
        # OAuth (requiring user to log back in to Google).
        # idToken has a lifetime of about 1 hour
        idinfo = id_token.verify_oauth2_token(idToken, requests.Request(), clientID)
    except ValueError:
        # Invalid or expired token
        return HttpResponse(status=511)  # 511 Network Authentication Required

    uid = idinfo['sub']
    # get username
    try:
        username = idinfo['name']
    except:
        username = "anonymous"

    # Compute token and add to database
    innerBackendSecret = "duyung"
    nonce = str(now)
    hashable = idToken + innerBackendSecret + nonce
    inner_temp = hashlib.sha256(hashable.strip().encode('utf-8')).hexdigest()
    outterBackendSecret = "pyhuang"
    hashable = inner_temp + outterBackendSecret
    token = hashlib.sha256(hashable.strip().encode('utf-8')).hexdigest()

    # Lifetime of token is min of time to idToken expiration
    # (int()+1 is just ceil()) and target lifetime, which should
    # be less than idToken lifetime (~1 hour).
    lifetime = min(int(idinfo['exp']-now)+1, 3500) # secs, up to idToken's lifetime

    cursor = connection.cursor()


    # insert new token
    
    cursor.execute('SELECT COUNT(*) FROM users WHERE uid = %s;', (uid,))
    (number_of_rows,) = cursor.fetchone()
    if number_of_rows == 0:
        cursor.execute('INSERT INTO users (uid, token, username, expiration) VALUES '
                   '(%s, %s, %s, %s);', (uid, token, username, now+lifetime))
    else:
        cursor.execute('UPDATE users SET token = %s, expiration = %s WHERE uid = %s;', (token, now+lifetime, uid))

    # Return token and its lifetime
    return JsonResponse({'token': token, 'lifetime': lifetime, 'username': username})

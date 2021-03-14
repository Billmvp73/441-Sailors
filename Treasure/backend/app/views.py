from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
from django.shortcuts import render
def getgames(request,city):
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM games ORDER BY time DESC;')
    rows = cursor.fetchall()
    new_rows = []
    for row in rows:
        location = row[4].split(',')[2].split('"')[1]
        if location == city:
            new_rows.append(row)
        if len(new_rows) == 25:
            break
        


    response = {}
    response['games'] = new_rows       # <<<<< NOTE: REPLACE dummy response WITH chatts <<<
    return JsonResponse(response)

@csrf_exempt
def postgames(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    cursor = connection.cursor()
    # assign a new gid
    cursor.execute('SELECT COUNT(*) FROM games;')
    gid = str(int(cursor.fetchone()[0])+1)
    username = json_data['username']
    gamename = json_data['gamename']
    description = json_data['description']
    tag = json_data['tag']
    location = json_data['location']
    cursor.execute('INSERT INTO games (gid, username, gamename, description, tag, location) VALUES '
                   '(%s, %s, %s, %s,%s, %s);', (gid, username, gamename, description, tag, location))
    return JsonResponse({})

from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import math
from django.shortcuts import render
def getgames(request,city_info):
    if request.method != 'GET':
        return HttpResponse(status=404)
    city = city_info.split('+')[0]
    latitude = float(city_info.split('+')[1])
    longitude = float(city_info.split('+')[2])

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM games ORDER BY time DESC;')
    rows = cursor.fetchall()
    new_rows = []
    index = 0
    distance = {}
    for row in rows:
        location = row[4].split(',')[2].split('"')[1]
        select_latitude = float(row[4].split(',')[0].split('[')[1])
        select_longitude = float(row[4].split(',')[1])
        distance = (latitude - select_latitude)**2 + (longitude-select_latitude)**2
        distance = math.sqrt(distance)
        if location == city:
            new_rows.append(row)
            distance[index] = distance
            index += 1
        if len(new_rows) == 25:
            break
    final_rows = []
    for w in sorted(distance, key=distance.get):
        final_rows.append(new_rows[w])
        
    response = {}
    response['games'] = final_rows       # <<<<< NOTE: REPLACE dummy response WITH chatts <<<
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

from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
from django.shortcuts import render
def getgames(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM games ORDER BY time DESC;')
    rows = cursor.fetchall()

    response = {}
    response['games'] = rows       # <<<<< NOTE: REPLACE dummy response WITH chatts <<<
    return JsonResponse(response)

@csrf_exempt
def postgames(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    username = json_data['username']
    message = json_data['message']
    tag = json_data['tag']
    location = json_data['location']
    cursor = connection.cursor()
    cursor.execute('INSERT INTO games (username, message, tag, location) VALUES '
                   '(%s, %s,%s, %s);', (username, message, tag, location))
    return JsonResponse({})

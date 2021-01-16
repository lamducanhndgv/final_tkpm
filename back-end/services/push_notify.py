## Install request module by running ->
#  pip3 install requests

# Replace the deviceToken key with the device Token for which you want to send push notification.
# Replace serverToken key with your serverKey from Firebase Console

# Run script by ->
# python3 fcm_python.py


import requests
import json

# firebase token
serverToken = 'AAAACEI-gqc:APA91bH3dDruvptTqBQFQr5foLivXPbl930V-PO-lz5ZgykEvjTMEcvL-7kNQA6NifeGyIaQy3-NpCWq1mSnUvKG3OilYxMUJLF10jNB7g_nX0rVPGIn3sr9FVpzSlvHiDDQm5Ga44OE'

# request header
headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=' + serverToken,
}

def push_notify(username, device_tokens):
        print(device_tokens)
        for child in device_tokens:
                if(child['token'] != ''):
                        body = {
                                'notification': {'title': 'New modellllllll',
                                                        'body': 'User {} has upload new model. Let check it out!'.format(username)
                                                },
                                'to': child['token'],
                                'priority': 'high',
                                #   'data': dataPayLoad,
                        }

                        response = requests.post("https://fcm.googleapis.com/fcm/send",headers = headers, data=json.dumps(body))

                        print(response.status_code)
                        print(response.json())
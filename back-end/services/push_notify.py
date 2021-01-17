import requests
import json

# firebase token
serverToken = 'AAAACEI-gqc:APA91bH3dDruvptTqBQFQr5foLivXPbl930V-PO-lz5ZgykEvjTMEcvL-7kNQA6NifeGyIaQy3-NpCWq1mSnUvKG3OilYxMUJLF10jNB7g_nX0rVPGIn3sr9FVpzSlvHiDDQm5Ga44OE'

# request header
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=' + serverToken,
}


def push_notify(db, sender, receivers, title, message):
    # save noti to db
    user = db.users.find_one({'username': sender}, {'_id': 0, 'others': 1})
    for other in user['others']:
        db.notifications.insert_one(
            {'username': other, 'title': title, 'message': message})

    # push firebase noti
    tokens = [receiver['token']
              for receiver in receivers if receiver['token'] != '']

    body = {
        'notification': {'title': title,
                         'body': message
                         },
        'registration_ids': tokens
    }

    response = requests.post(
        "https://fcm.googleapis.com/fcm/send", headers=headers, data=json.dumps(body))


def push_notify_subscribe(db, subscribe_user, title, message):
    # save noti to db
    db.notifications.insert_one(
        {'username': subscribe_user, 'title': title, 'message': message})

    user_token = db.users.find_one({'username': subscribe_user}, {
                                   '_id': 0, 'device_token': 1})
    subscribe_user_token = user_token['device_token']

    body = {
        'notification': {'title': title,
                         'body': message
                         },
        'to':
        subscribe_user_token,
        'priority': 'high',
    }

    response = requests.post(
        "https://fcm.googleapis.com/fcm/send", headers=headers, data=json.dumps(body))

    print(response.status_code)

    print(response.json())

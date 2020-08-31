from flask import Flask, url_for, request, session, redirect
from flask_pymongo import PyMongo
import bcrypt
import jwt

app = Flask(__name__)

app.config['MONGO_DBNAME'] = 'tkpm_final'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/tkpm_final'

mongo = PyMongo(app)

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    users = mongo.db.users

    # find username in database
    login_user = users.find_one({'username': data['username']})

    # if username exist, then we check hashed password
    if login_user:
        if bcrypt.checkpw(data['password'].encode('utf-8'), login_user['password']):
            session['username'] = data['username']
            encoded_jwt = jwt.encode({'id': str(login_user['_id'])}, 'secret', algorithm='HS256')

            # if success return token and http status code 200
            return encoded_jwt,200

    # http status code 401
    return 'Incorrect username or password',401

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    users = mongo.db.users
    
    existing_user = users.find_one({'username': data['username']})

    if existing_user is None:
        hashpass = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
        users.insert({'username': data['username'], 'password': hashpass})
        session['username'] = data['username']

        # http status code 200
        return '',200
    
    # http status code 400
    return 'Username is already exists!',400


if __name__ == '__main__':
    app.secret_key = 'secret'
    app.run(debug=True, port=8888)
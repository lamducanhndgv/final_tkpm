import io
import json
import os
import urllib.request

import bcrypt
import jwt
import zipfile36 as zipfile
from PIL import Image
from flask import Flask, render_template, request, session, redirect, jsonify
from flask_cors import CORS
from flask_pymongo import PyMongo
from werkzeug.utils import secure_filename

from helpers.createDir import make_dir, is_path_existing
from helpers.getUsername import get_username
from helpers.RequestInference import RequestInference
from middlewares.token_require import token_require

app = Flask(__name__)
# CORS(app)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

app.config['MONGO_DBNAME'] = 'tkpm_final'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/tkpm_final'
app.config['DATA_FOLDER'] = "E:\\LamAnh\\ThietKePhanMem\\final_project\\data"

mongo = PyMongo(app)


@app.route('/', methods=['GET'])
# @cross_origin()
def get_index():
    if 'username' in session:
        return render_template('index.html', name=session['username'])
    return redirect('/login')


@app.route('/', methods=['POST'])
# @cross_origin()
@token_require
def post_index():
    req = request.form
    modelname = req.get('modelname')
    config = req.get('config')

    os.chdir(app.config["DATA_FOLDER"])

    parent_dir = make_dir('users/' + session['username'])

    if is_path_existing(parent_dir + '/' + modelname):
        return jsonify(status=500, message='Models name exists!'), 500

    model_dir = make_dir(parent_dir + '/' + modelname)

    print(config)

    # with open(model_dir + '/config.json', 'w') as out_file:
    #     out_file.write(config)

    curr_dir = make_dir(model_dir + '/source')

    f = request.files['file']
    filepath = curr_dir + '/' + secure_filename(f.filename)
    f.save(filepath)
    with zipfile.ZipFile(filepath, 'r') as zip_ref:
        zip_ref.extractall(curr_dir)
    os.remove(filepath)

    # insert model's name of user into database
    models = mongo.db.models
    models.insert({'username': session['username'], 'modelname': modelname})

    return jsonify(status=200, message='File upload successful!'), 200


@app.route('/login', methods=['POST', 'GET'])
# @cross_origin()
def login():
    if request.method == 'POST':
        data = json.loads(request.data)
        users = mongo.db.users
        models = mongo.db.models

        login_user = users.find_one({'username': data['username']})

        if login_user:
            if bcrypt.checkpw(data['password'].encode('utf-8'), login_user['password']):
                session['username'] = data['username']
                encoded_jwt = jwt.encode({'username': data['username']}, 'secret', algorithm='HS256')

                listmodels = []
                for models in models.find({'username': data['username']}):
                    listmodels.append(models['modelname'])

                return jsonify(status=200,
                               message='Login successfully!',
                               listmodels=listmodels,
                               token=encoded_jwt.decode('utf-8')), 200

        return jsonify(status=401,
                       message='Incorrect username or password'), 401

    if 'username' in session:
        return redirect('/')

    return render_template('login.html')


@app.route('/register', methods=['POST', 'GET'])
# @cross_origin()
def register():
    if request.method == 'POST':
        data = json.loads(request.data)
        users = mongo.db.users

        existing_user = users.find_one({'username': data['username']})

        if existing_user is None:
            hashpass = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
            users.insert({'username': data['username'], 'password': hashpass})
            session['username'] = data['username']
            os.chdir(app.config["DATA_FOLDER"])
            make_dir('users/', data['username'] + '/images')

            return jsonify(status=200,
                           message='Register completed!'), 200

        # http status code 400
        return jsonify(status=400,
                       message='Username is already exists!'), 400

    if 'username' in session:
        return redirect('/')

    return render_template('register.html')


@app.route('/detection/url', methods=['POST'])
@token_require
def mainUrlDetection():
    # Get information from request
    requestData = str(request.data, 'utf-8')
    data = json.loads(requestData)
    img_url = data['url']
    model_name = data['model']
    username = get_username(request.headers['Authorization'])

    # Save data to storage
    os.chdir(app.config["DATA_FOLDER"])
    img = Image.open(urllib.request.urlopen(img_url)).save('users/{0}/images/{0}.jpg'.format(secure_filename(username)))

    res = RequestInference(username, model_name, f"{secure_filename(username)}.jpg")()
    print(res)

    return jsonify(status=200, message='Uploaded ok!'), 200


@app.route('/detection/file', methods=['POST'])
# @token_require
def main2():
    # Get information from request
    img = request.files["image"].read();
    model_name = request.form.to_dict(flat=False)['model'][0];
    username = get_username(request.headers['Authorization'])

    # Save data to storage
    os.chdir(app.config["DATA_FOLDER"])
    Image.open(io.BytesIO(img)).save('users/{0}/images/{0}.jpg'.format(secure_filename(username)))

    res = RequestInference(username, model_name, f"{secure_filename(username)}.jpg")()
    print(res)

    return jsonify(status=200, message='Uploaded ok!'), 200


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify(status=200,
                   message='Logout successfully!'), 200


if __name__ == '__main__':
    app.secret_key = 'secret'
    RequestInference.DATA_FOLDER = app.config["DATA_FOLDER"]
    app.run(host='0.0.0.0', debug=True, port=8888)

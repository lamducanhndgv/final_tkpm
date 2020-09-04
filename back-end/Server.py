from flask import Flask,  render_template, url_for, request, session, redirect, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS, cross_origin
from middlewares.token_require import token_require
from helpers.createDir import make_dir
from helpers.createDir import is_path_existing
from werkzeug.utils import secure_filename
import zipfile36 as zipfile
import bcrypt
import jwt
import json
import os

app = Flask(__name__)
# CORS(app)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

app.config['MONGO_DBNAME'] = 'tkpm_final'
app.config['MONGO_URI'] = 'mongodb://localhost:27017/tkpm_final'

mongo = PyMongo(app)


@app.route('/', methods=['GET'])
def get_index():
    if 'username' in session:
        return render_template('index.html', name=session['username'])
    return redirect('/login')


@app.route('/', methods=['POST'])
@token_require
def post_index():
    req = request.form
    modelname = req.get('modelname')

    parent_dir = make_dir('users/', session['username'])
    if is_path_existing(parent_dir+'/'+modelname):
        return jsonify(status=500, message='Models name exists!'),500
    curr_dir = make_dir(parent_dir+'/', modelname)

    f = request.files['file']
    filepath = curr_dir + '/' + secure_filename(f.filename)
    f.save(filepath)
    with zipfile.ZipFile(filepath, 'r') as zip_ref:
        zip_ref.extractall(curr_dir)
    os.remove(filepath)
    
    # insert model's name of user into database
    models = mongo.db.models
    models.insert({'username': session['username'], 'modelname': modelname})

    return jsonify(status=200, message='File upload successful!'),200

@app.route('/login', methods=['POST','GET'])
def login():
    if request.method == 'POST':
        data = json.loads(request.data)
        users = mongo.db.users
        models = mongo.db.models

        # find username in database
        login_user = users.find_one({'username': data['username']})

        # if username exist, then we check hashed password
        if login_user:
            if bcrypt.checkpw(data['password'].encode('utf-8'), login_user['password']):
                session['username'] = data['username']
                encoded_jwt = jwt.encode({'id': str(login_user['_id'])}, 'secret', algorithm='HS256')

                listmodels = []
                for models in models.find({'username': data['username']}):
                    listmodels.append(models['modelname'])

                # if success return token and http status code 200
                return jsonify(status=200,
                                message='Login successfully!',
                                listmodels=listmodels,
                                token=encoded_jwt.decode('utf-8') ),200

        # http status code 401
        return jsonify(status=401, 
                        message='Incorrect username or password'),401
    
    if 'username' in session:
        return redirect('/')

    return render_template('login.html')


@app.route('/register', methods=['POST','GET'])
def register():
    if request.method == 'POST':
        data = json.loads(request.data)
        users = mongo.db.users
        
        existing_user = users.find_one({'username': data['username']})

        if existing_user is None:
            hashpass = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
            users.insert({'username': data['username'], 'password': hashpass})
            session['username'] = data['username']
            
            make_dir('users/', session['username'])

            # http status code 200
            return jsonify(status=200,
                            message='Register completed!'),200
        
        # http status code 400
        return jsonify(status=400,
                        message='Username is already exists!'),400
    
    if 'username' in session:
        return redirect('/')

    return render_template('register.html')

# @app.route('/detection/url', methods=['POST'])
# def mainUrlDetection():
#     print('detection url')
#     requestData=str(request.data,'utf-8')
#     data = json.loads(requestData)
#     imgUrl= data['url']
#     modelName = data['model']
#     img = Image.open(urllib.request.urlopen(imgUrl))
#     return create_response_from_image(img,default_nets,default_layer,default_labels,default_colors)

# @app.route('/detection/file', methods=['POST'])
# def main2():
#     img = request.files["image"].read();
#     model = request.form.to_dict(flat=False)['model'][0];
#     img = Image.open(io.BytesIO(img))
#     # predict
#     return create_response_from_image(img,default_nets,default_layer,default_labels,default_colors)

@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify(status=200,
                    message='Logout successfully!'), 200

if __name__ == '__main__':
    app.secret_key = 'secret'
    app.run(host='0.0.0.0',debug=True, port=8888)
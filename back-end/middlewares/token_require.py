from flask import jsonify, request
import jwt
from functools import wraps

def token_require(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        # token = request.args.get('token')
        token = request.headers['Authorization']

        if not token:
            return jsonify(message='Authentication error!'),401
        
        try:
            data = jwt.decode(token, 'secret')
        except:
            return jsonify(message='Authentication error!'),401

        return f(*args, **kwargs)

    return decorated
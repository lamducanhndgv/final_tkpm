import jwt

def get_username(token):
    return jwt.decode(token, 'secret')['username']
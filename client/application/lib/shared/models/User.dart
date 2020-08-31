class User {
  String username;

//  String _password;
  String token;
  String modelNames;

  User({this.username, this.token, this.modelNames});
//
//  User.map(dynamic obj){
//    this._username = obj['username'];
//    this._password = obj['password'];
//
//  }
//  String get username=>_username;
//  String get password =>_password;
//
//  Map<String, dynamic>toMap(){
//    var map = new Map<String,dynamic>();
//    map['username']= _username;
//    map['password']=_password;
//    return map;
//  }
  factory User.fromJson(Map<String, dynamic> map) {
    print('Factory user model from json:');
    return User(
//        username: map['username'],
        token: map['token'],);
//        modelNames: map['modelnames']);
  }
}

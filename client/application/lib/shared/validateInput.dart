import 'package:regexed_validator/regexed_validator.dart';

class Validation{
  static isPassValid(String password){
    if(password==null) return false;
    return password.length>6;
  }
  static isUsernameValid(String user){
    if(user==null) return false;
    return user.length>5;
  }

  static isIPvalid(String IP) {
      return validator.ip(IP);
  }

  static bool isValidURL(String url) {
    return validator.url(url);
  }
}
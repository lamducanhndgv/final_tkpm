import 'package:regexed_validator/regexed_validator.dart';
class Validation{
  static isPassValid(String password,int length){
    if(password==null) return false;
    return password.length>length;
  }
  static isUsernameValid(String user, int length){
    if(user==null) return false;
    return user.length>length;
  }

  static isIPvalid(String ip) {
      return validator.ip(ip);
  }

  static bool isValidURL(String url) {
    return validator.url(url);
  }

}
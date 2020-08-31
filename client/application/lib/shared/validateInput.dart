class Validation{
  static isPassValid(String password){
    if(password==null) return false;
    return password.length>6;
  }
  static isUsernameValid(String user){
    if(user==null) return false;
    return user.length>5;
  }
}
import 'package:application/models/User.dart';
import 'package:application/utils/NetworkUtils.dart';
import 'package:application/utils/assets.dart';

class RestData{
  NetworkUtils _networkUtils = new NetworkUtils();

  static final BASE_URL =SERVER_URL;
  static final LOGIN_URL = BASE_URL+"/";

  Future<User> login(String username, String password){
    // Do something with server
    return new Future.value(new User(username,password));
  }
}

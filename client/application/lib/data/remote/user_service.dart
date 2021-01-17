import 'package:dio/dio.dart';
import 'package:application/network/server.dart';

class UserService {
  Future<Response> signIn(String user, String pass,String tokenDevice) {
    print('Call sign in from user service');
    return DetectClient.instance.dio.post(
      '/login',
      data: {
        'username': user,
        'password': pass,
        'device_token': tokenDevice,
      },
    );
  }

  Future<Response> signUp(String user, String pass) {
    print('Call sign up from user service');
    return DetectClient.instance.dio.post(
      '/register',
      data: {
        'username': user,
        'password': pass,
      },
    );
  }

  changeServerAddress(String newIP) {
    print('Call change from user service');
    DetectClient.setServerIP(newIP);
  }

}

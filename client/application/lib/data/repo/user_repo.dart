import 'dart:async';
import 'package:application/shared/models/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:application/data/remote/user_service.dart';
import 'package:application/data/spref/spref.dart';
import 'package:application/shared/constant.dart';

// Work with network

class UserRepo {
  UserService _userService;

  UserRepo({@required UserService userService}) : this._userService = userService;

  Future<User> signIn(String username, String pass) async {
    // Callback
    print('Call signin from user repo');
    var c = Completer<User>();
    try {
      var response = await _userService.signIn(username, pass);
      var user = User.fromJson(response.data);
      if (user != null) {
        SPref.instance.set(SPrefCache.KEY_TOKEN, user.token);
        SPref.instance.set(SPrefCache.MODEL_NAMES,user.modelNames);
        c.complete(user);
      }
    } on DioError catch (e) {
      print(e.response.data);
      c.completeError('${e.response.data['message']}');
    }
    catch (e) {
      print(e.toString());
      print('catch error from user repos');
      c.completeError(e);
    }
    return c.future;
  }
  Future<bool> signUp(String username, String pass) async {
    // Callback
    print('Call sign up from user repo');
    var c = Completer<bool>();
    try {
      var response = await _userService.signUp(username, pass);
//      var user = User.fromJson(response.data['data']);
      if (response.data['status']==200) {
//        SPref.instance.set(SPrefCache.KEY_TOKEN, user.token);
        c.complete(true);
      }
      else{
        c.completeError('${response.data['message']}');
      }
    } on DioError catch (e) {
      print(e.response.data);
      c.completeError('${e.response.data['message']}');
    } catch (e) {
      print('catch error from user repos');
      c.completeError(e);
    }

    return c.future;
  }

  changeServerAddress(String newIP){
    print('Call change from user repo');
    _userService.changeServerAddress(newIP);
  }
}

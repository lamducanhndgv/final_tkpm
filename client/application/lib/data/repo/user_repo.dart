import 'dart:convert';
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
      print('response data in repo sign in: '+ response.data);
      var user = User.fromJson(response.data['data']);
      if (user != null) {
        SPref.instance.set(SPrefCache.KEY_TOKEN, user.token);
        c.complete(user);
      }
    } on DioError catch (e) {
      print(e.response.data);
      c.completeError('Login Error');
    } catch (e) {
      print('catch error from user repos');
      c.completeError(e);
    }

    return c.future;
  }
  Future<User> signUp(String username, String pass) async {
    // Callback
    print('Call sign up from user repo');
    var c = Completer<User>();
    try {
      var response = await _userService.signIn(username, pass);
      print('response data in repo sign up: '+ response.data);
      var user = User.fromJson(response.data['data']);
      if (user != null) {
        SPref.instance.set(SPrefCache.KEY_TOKEN, user.token);
        c.complete(user);
      }
    } on DioError catch (e) {
      print(e.response.data);
      c.completeError('Register Error');
    } catch (e) {
      print('catch error from user repos');
      c.completeError(e);
    }

    return c.future;
  }
}

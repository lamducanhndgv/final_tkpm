import 'dart:convert';

import 'package:application/data/spref/spref.dart';
import 'package:application/module/dialog/Dialog.dart';
import 'package:application/shared/constant.dart';
import 'package:flutter/cupertino.dart';

class User {
  String username;
  String token;
  String modelNames;
  User({this.username, @required this.token, this.modelNames});
  factory User.fromJson(Map<String, dynamic> map)  {
    print(map);
    print('Factory user model from json:');
    String x = "";
    String logs = "[";
    if ( map['listmodels']!=null) {
      for (String model in map['listmodels']) {
        print(model);
        if(!x.contains(model.toString()))
        x += model.toString() + ",";
      }
      x = x.substring(0, x.length - 1);
    }
    if(x!=null &&x.length<2) x=null;
    if( map['notify_logs']!=null){
      for(dynamic a in map['notify_logs']){
       logs+=ModelNotification.fromJson(a).toString() +",";
      }
      logs=logs.replaceRange(logs.length-1, logs.length, "]");
      SPref.instance.set(SPrefCache.NOTIFY_LOGS,logs);
    }
    return User(
        token: map['token'],
        modelNames: x);
  }
}

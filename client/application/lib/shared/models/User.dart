import 'package:application/data/spref/spref.dart';
import 'package:application/shared/constant.dart';
import 'package:flutter/cupertino.dart';

class User {
  String username;
  String token;
  String modelNames;
  User({this.username, @required this.token, this.modelNames});
  factory User.fromJson(Map<String, dynamic> map)  {

    print('Factory user model from json:');
    String x = "";
    String logs = "";
    if ( map['listmodels']!=null && map['listmodels'].length > 1) {
      for (String model in map['listmodels']) {
        x += model.toString() + ",";
      }
      x = x.substring(0, x.length - 1);
    }
    if(x!=null &&x.length<2) x=null;
    if( map['notify_logs']!=null && map['notify_logs'].length >1){
      SPref.instance.set(SPrefCache.NOTIFY_LOGS,map['notify_logs']);
    }
    return User(
        token: map['token'],
        modelNames: x);
  }
}

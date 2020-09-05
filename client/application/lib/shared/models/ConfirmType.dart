import 'package:flutter/cupertino.dart';

class ConfirmType{
  String password;
  String confirm;
  ConfirmType({this.password,@required this.confirm});

  @override
  String toString() {
    return confirm;
  }
}
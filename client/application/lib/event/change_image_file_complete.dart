import 'dart:io';
import 'package:application/base/base_event.dart';
import 'package:flutter/cupertino.dart';

class ChangeImgFileComplete extends BaseEvent{
  File imageFile;
  ChangeImgFileComplete({@required this.imageFile}){
  }
}

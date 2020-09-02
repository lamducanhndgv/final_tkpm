
import 'package:application/base/base_event.dart';
import 'package:flutter/cupertino.dart';

class ChangeImgURLComplete extends BaseEvent{
  StringBuffer buffer;
  ChangeImgURLComplete({@required this.buffer}){
    print(buffer.toString()+' === from change url complete');
  }
}

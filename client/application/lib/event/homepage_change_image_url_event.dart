import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class ChangeImgURL extends BaseEvent {
  String newURL;
  ChangeImgURL({@required this.newURL});
}

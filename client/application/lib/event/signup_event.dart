import 'package:application/base/base_event.dart';
import 'package:flutter/widgets.dart';

class SignUpEvent extends BaseEvent {
  String username;
  String pass;

  SignUpEvent({@required this.username, @required this.pass});
}

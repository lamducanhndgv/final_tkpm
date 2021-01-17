import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class SignInEvent extends BaseEvent {
  String username;
  String pass;
  String tokenDevice;
  SignInEvent({@required this.username, @required this.pass, this.tokenDevice});
}

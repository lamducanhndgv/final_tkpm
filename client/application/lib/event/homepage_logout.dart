import 'package:application/base/base_event.dart';
import 'package:flutter/widgets.dart';

class LogoutEvent extends BaseEvent {
  String username;

  LogoutEvent({@required this.username});
}

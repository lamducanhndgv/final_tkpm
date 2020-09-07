import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class ChangeIPEvent extends BaseEvent {
  String newIP;

  ChangeIPEvent({@required this.newIP});
}

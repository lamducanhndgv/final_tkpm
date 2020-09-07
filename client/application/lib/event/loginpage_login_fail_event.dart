
import 'package:application/base/base_event.dart';

class LoginFailEvent extends BaseEvent{
  final String errMessage;
  LoginFailEvent(this.errMessage);
}

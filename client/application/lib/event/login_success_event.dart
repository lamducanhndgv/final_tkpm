import 'package:application/base/base_event.dart';
import 'package:application/shared/models/User.dart';

class LoginSuccessEvent extends BaseEvent{
  final User userData;
  LoginSuccessEvent(this.userData);
}
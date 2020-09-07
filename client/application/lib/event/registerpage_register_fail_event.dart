
import 'package:application/base/base_event.dart';

class RegisterFail extends BaseEvent{
  final String errMessage;
  RegisterFail(this.errMessage);
}

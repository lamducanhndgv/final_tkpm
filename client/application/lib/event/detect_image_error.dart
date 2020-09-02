import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class DetectImageError extends BaseEvent {
  String message;
  DetectImageError({@required this.message});
}

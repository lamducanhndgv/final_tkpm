import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class DetectImageComplete extends BaseEvent {
  Uint8List bytesImage;
  DetectImageComplete({@required this.bytesImage});
}

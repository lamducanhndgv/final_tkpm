import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:application/base/base_event.dart';

class DetectImageEvent extends BaseEvent {
  String urlImage;
  File fileImage;
  String modelName;

  DetectImageEvent({@required this.modelName, this.urlImage, this.fileImage});
}

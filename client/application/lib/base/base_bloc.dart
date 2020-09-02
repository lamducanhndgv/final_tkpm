import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'base_event.dart';

abstract class BaseBloc {
  StreamController<BaseEvent> _eventStreamController =
      StreamController<BaseEvent>();

  StreamController<bool> _isLoading =StreamController<bool>();
  Stream<bool> get loadingStream => _isLoading.stream;
  Sink<bool> get loadingSink =>_isLoading.sink;

  Sink<BaseEvent> get event => _eventStreamController.sink;

  StreamController<BaseEvent> _processStreamController = BehaviorSubject<BaseEvent>();
  Stream<BaseEvent> get processStream => _processStreamController.stream;
  Sink<BaseEvent> get processSink =>_processStreamController.sink;

  BaseBloc() {
    _eventStreamController.stream.listen((event) {
      if (event is! BaseEvent) {
        throw Exception("Invalid event");
      }

      dispatchEvent(event);
    });
  }

  void dispatchEvent(BaseEvent event);

  @mustCallSuper
  void dispose() {
    _eventStreamController.close();
    _processStreamController.close();
    _isLoading.close();
  }
}

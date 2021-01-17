import 'dart:async';

import 'package:application/base/base_bloc.dart';
import 'package:application/base/base_event.dart';
import 'package:application/data/repo/detect_repo.dart';
import 'package:application/event/homepage_change_image_cam_event.dart';
import 'package:application/event/homepage_change_image_file.dart';
import 'package:application/event/homepage_change_image_file_complete.dart';
import 'package:application/event/homepage_change_image_file_notpick.dart';
import 'package:application/event/homepage_change_image_url_complete.dart';
import 'package:application/event/homepage_change_image_url_event.dart';
import 'package:application/event/homepage_detect_image_complete.dart';
import 'package:application/event/homepage_detect_image_error.dart';
import 'package:application/event/homepage_detect_image_event.dart';
import 'package:application/event/homepage_logout.dart';
import 'package:application/shared/validateInput.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class HomePageBloc extends BaseBloc {
  DetectRepos _detectRepos;

  final _urlSubject = BehaviorSubject<String>();
  final _btnChangeImageURLSubject = BehaviorSubject<bool>();
  final _btnDetectSubject = BehaviorSubject<bool>();

  @override
  void dispose() {
    super.dispose();
    _urlSubject.close();
    _btnChangeImageURLSubject.close();
    _btnDetectSubject.close();
  }

  HomePageBloc({@required DetectRepos detectRepos}) {
    this._detectRepos = detectRepos;
    combineChangeURLform();
  }

  var urlValidate =
      StreamTransformer<String, String>.fromHandlers(handleData: (url, sink) {
    if (Validation.isValidURL(url))
      sink.add(null);
    else {
      sink.add('URL invalid');
    }
  });

  combineChangeURLform() {
    Rx.combineLatest([_urlSubject], (values) {
      return values.join("");
    }).listen((event) {
      if (Validation.isValidURL(event.toString())) {
        btnChangeImgSink.add(true);
      } else {
        btnChangeImgSink.add(false);
      }
    });
  }

  Stream<String> get urlStream => _urlSubject.stream.transform(urlValidate);

  Sink<String> get urlSink => _urlSubject.sink;

  Stream<bool> get btnChangeImgURStream => _btnChangeImageURLSubject.stream;

  Sink<bool> get btnChangeImgSink => _btnChangeImageURLSubject.sink;
  Stream<bool> get btnDetectStream => _btnDetectSubject.stream;

  Sink<bool> get btnDetectSink => _btnDetectSubject.sink;

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case ChangeImgURL:
        handleChangeImg(event);
        break;
      case ChangeImgInGallery:
        handleChooseInGallery(event);
        break;
      case ChangeImgByCamera:
        handleChooseByCamera(event);
        break;
      case DetectImageEvent:
        handleDetectImage(event);
        break;
      case LogoutEvent:
        handleLogout(event);
        break;
    }
  }

  handleChangeImg(BaseEvent event) async {
    ChangeImgURL e = event as ChangeImgURL;
    print('Change img url in home bloc');
    StringBuffer newBuf = new StringBuffer(e.newURL);
    processSink.add(ChangeImgURLComplete(buffer: newBuf));
  }

  handleChooseInGallery(BaseEvent event) async {
    ChangeImgInGallery e = event as ChangeImgInGallery;
    // ignore: deprecated_member_use
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null)
      processSink.add(ChangeImgFileComplete(imageFile: pickedImage));
    else
      processSink.add(ChangeImgFileNotPick(context: e.context));
    Navigator.of(e.context).pop();
  }

  handleChooseByCamera(BaseEvent event) async {
    ChangeImgByCamera e = event as ChangeImgByCamera;
    // ignore: deprecated_member_use
    var pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null)
      processSink.add(ChangeImgFileComplete(imageFile: pickedImage));
    else
      processSink.add(ChangeImgFileNotPick(context: e.context));
    Navigator.of(e.context).pop();
  }

  handleDetectImage(BaseEvent event) async {
    loadingSink.add(true);
    btnDetectSink.add(false);
    print('Detect image, loading sink true');
    // Future.delayed(Duration(seconds: 15), () {
    DetectImageEvent e = event as DetectImageEvent;
    if (e.urlImage != null) {
      _detectRepos.detectByURL(e.urlImage, e.modelName).then((result) {
        loadingSink.add(false);
        btnDetectSink.add(true);
        processSink.add(DetectImageComplete(bytesImage: result));
      }, onError: (error) {
        print(error.toString());
        loadingSink.add(false);
        btnDetectSink.add(true);
        print('Detect image, loading sink FALSE12');
        processSink.add(DetectImageError(message: error.toString()));
      });
    } else if (e.fileImage != null) {
      _detectRepos.detectByImage(e.fileImage, e.modelName).then((result) {
        // print(result.length);
        loadingSink.add(false);
        btnDetectSink.add(true);
        processSink.add(DetectImageComplete(bytesImage: result));
      }, onError: (error) {
        print(error.toString());
        loadingSink.add(false);
        btnDetectSink.add(true);
        print('Detect image, loading sink FALSE2');
        processSink.add(DetectImageError(message: error.toString()));
      });
    }
  }

  void handleLogout(BaseEvent event) async {
    LogoutEvent e = event as LogoutEvent;
    if(e.username!=null){
      _detectRepos.signOut(e.username).catchError((e){
        print('Logout Error: '+ e.toString());
      });
    }
  }
}

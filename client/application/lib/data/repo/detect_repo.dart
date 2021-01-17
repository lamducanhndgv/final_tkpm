import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:application/data/remote/detect_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class DetectRepos{
  DetectService _detectService;
  DetectRepos({@required DetectService detectService}):_detectService = detectService;
  Future<void> signOut(String username)async{
    var c = Completer<void>();
    try{
      await _detectService.signOut(username);
    }catch(e){
      c.complete(e);
    }
  }
  Future<Uint8List> detectByImage(File imageFile, String model) async {
    print('Repos Detect by file');
    var c = Completer<Uint8List>();
    try {
      var response = await _detectService.sendImageToDetect(imageFile,model);
      var r = await response.data;
      c.complete(r);
    } on DioError catch (e1) {
      print(String.fromCharCodes(e1.response.data));
      c.completeError('${(String.fromCharCodes(e1.response.data))}');
    } catch (e2) {
      print(e2.response.data.runtimeType.toString());
      print('Catch error from user repos');
      c.completeError(e2);
    }
    return c.future;
  }
  Future<Uint8List> detectByURL(String url,String model) async {
    print('Repos Detect by url');

    var c = Completer<Uint8List>();
    try {
      var response = await _detectService.sendURLToDetect(url,model);
      var r = await response.data;
      c.complete(r);
    } on DioError catch (e1) {
      print(String.fromCharCodes(e1.response.data));
      c.completeError('${(String.fromCharCodes(e1.response.data))}');
    } catch (e2) {
      print(e2.response.data.runtimeType.toString());
      print('Catch error from user repos');
      c.completeError(e2);
    }
    return c.future;
  }

}
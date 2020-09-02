import 'dart:io';

import 'package:dio/dio.dart';
import 'package:application/network/server.dart';

class DetectService {
  Future<Response> sendImageToDetect(File imageFile, String model) async {
    print('Detect service send file');
    String fileName = imageFile.path.split('/').last;
    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      "model": model,
    });
    print(data.toString());
    return DetectClient.instance.dio.post('/detection/file',
        data: data, options: Options(responseType: ResponseType.bytes));
  }

  Future<Response> sendURLToDetect(String url, String model) async {
    print('Detect service send url');
    print('url $url , model : $model');
    return DetectClient.instance.dio.post('/detection/url',
        data: {"url": url, "model": model},
        options: Options(responseType: ResponseType.bytes));
  }
}

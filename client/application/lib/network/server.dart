import 'package:application/data/spref/spref.dart';
import 'package:application/shared/constant.dart';
import 'package:dio/dio.dart';

class DetectClient {
  static const PORT = '8888';
  static var urlServer = 'http://192.168.1.2:$PORT';
  static BaseOptions _options = new BaseOptions(
    baseUrl: urlServer,
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  static Dio _dio = Dio(_options);

  DetectClient._internal() {
    _dio.interceptors.add(LogInterceptor(responseBody: false));
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options option) async {
      var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
      if (token != null) {
        option.headers["Authorization"] = "Bearer " + token;
      }
      return option;
    }));
  }

  static final DetectClient instance = DetectClient._internal();

  static setServerIP(String newIP) {
    urlServer = 'http://' + newIP + ':$PORT';
    _options.baseUrl = urlServer;
  }

  Dio get dio => _dio;
}

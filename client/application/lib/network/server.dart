import 'package:application/data/spref/spref.dart';
import 'package:application/shared/constant.dart';
import 'package:dio/dio.dart';

class DetectClient {
  static const PORT = '8888';
  static var urlServer = 'http://192d8f4e5f97.ngrok.io';
  static BaseOptions _options = new BaseOptions(
    baseUrl: urlServer,
    connectTimeout: 20000,
    receiveTimeout: 10000,
  );
  static Dio _dio = Dio(_options);

  DetectClient._internal() {
    print('dio get instance internal');
    _dio.interceptors.add(LogInterceptor(responseBody: false));
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options option) async {
      var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
      if (token != null) {
        option.headers["Authorization"] =  token;
      }
      return option;
    }));
  }

  static final DetectClient instance = DetectClient._internal();

  static setServerIP(String newIP) {
    // urlServer = 'http://' + newIP + ':$PORT';
    _options.baseUrl = urlServer;
    SPref.instance.set(SPrefCache.CURRENT_IP_SERVER, newIP);
  }

  Dio get dio => _dio;
}

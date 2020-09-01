import 'package:application/data/spref/spref.dart';
import 'package:application/shared/constant.dart';
import 'package:dio/dio.dart';

class DetectClient {
  static BaseOptions _options = new BaseOptions(
    baseUrl: "http://192.168.1.9:8888",
    
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  static Dio _dio = Dio(_options);

  DetectClient._internal() {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
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

  Dio get dio => _dio;
}

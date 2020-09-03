class NetworkUtils{
  static NetworkUtils _instance = new NetworkUtils.internal();
  NetworkUtils.internal();
  factory NetworkUtils()=>_instance;
  Future<dynamic> get(){
    return null;
  }
}
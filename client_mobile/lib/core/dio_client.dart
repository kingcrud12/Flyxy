import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  static PersistCookieJar? cookieJar;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8083/api/v1/'),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  static Future<void> init(String cookiePath) async {
    cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath + "/.cookies/"),
    );
    _instance.dio.interceptors.add(CookieManager(cookieJar!));
  }
}

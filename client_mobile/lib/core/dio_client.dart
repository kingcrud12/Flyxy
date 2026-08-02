import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

String _getBaseUrl() {
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://10.0.2.2:8083/api/v1/'; // Android Emulator localhost
  }
  
  const envUrl = String.fromEnvironment('API_URL');
  if (envUrl.isNotEmpty) return envUrl;
  
  return 'http://127.0.0.1:8083/api/v1/'; // iOS Simulator / Mac localhost
}

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  static PersistCookieJar? cookieJar;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _getBaseUrl(),
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

  static Future<void> clearCookies() async {
    if (cookieJar != null) {
      await cookieJar!.deleteAll();
    }
  }
}

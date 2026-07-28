import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class AuthService {
  late Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      // L'IP Wi-Fi exacte de votre Mac sur votre réseau local est 10.1.2.52.
      // 194.x.x.x était probablement votre adresse IP publique, ou 127.0.0.1 pointait vers le téléphone lui-même.
      baseUrl: 'http://10.1.2.52:8081/api/v1',
    ));
    // Le CookieManager va capturer le 'Set-Cookie' lors du login et l'attacher aux requêtes suivantes
    _dio.interceptors.add(CookieManager(CookieJar()));
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    await _dio.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    });
  }

  Future<void> login(String email, String password) async {
    // Cette requête va renvoyer un Cookie HttpOnly capturé par le CookieJar
    await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    // Le cookie est envoyé automatiquement ici
    final response = await _dio.get('/me');
    return response.data;
  }
}

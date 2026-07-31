import 'package:dio/dio.dart';
import '../core/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  AuthService();

  Future<void> register(String firstName, String lastName, String email, String password) async {
    await _dio.post('auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    });
  }

  Future<void> login(String email, String password) async {
    // Cette requête va renvoyer un Cookie HttpOnly capturé par le CookieJar
    await _dio.post('auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    // Le cookie est envoyé automatiquement ici
    final response = await _dio.get('me');
    return response.data;
  }

  Future<String> uploadAvatar(dynamic file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    
    final response = await _dio.post('users/me/avatar', data: formData);
    return response.data['url'];
  }
}

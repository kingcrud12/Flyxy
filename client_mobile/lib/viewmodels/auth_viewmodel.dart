import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _firstName = "";
  String get firstName => _firstName;

  String _lastName = "";
  String get lastName => _lastName;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.login(email, password);
      final profile = await _authService.getMe();
      _firstName = profile['first_name'];
      _lastName = profile['last_name'];
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is DioException) {
        print("DIO EXCEPTION: ${e.message} | ${e.type}");
        if (e.response?.statusCode == 401) {
          _error = "Identifiants incorrects";
        } else {
          _error = "Erreur réseau: Impossible de joindre le serveur";
        }
      } else {
        print("UNKNOWN EXCEPTION: $e");
        _error = "Erreur inconnue";
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String firstName, String lastName, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.register(firstName, lastName, email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = "Erreur réseau ou d'inscription";
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _firstName = "";
    _lastName = "";
    // Dans l'idéal, il faudrait appeler une route /logout pour vider le cookie HttpOnly
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

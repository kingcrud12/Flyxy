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

  String _email = "";
  String get email => _email;

  String _userId = "";
  String get userId => _userId;

  String _profilePicture = "";
  String get profilePicture => _profilePicture;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.login(email, password);
      final profile = await _authService.getMe();
      _firstName = profile['first_name'] ?? '';
      _lastName = profile['last_name'] ?? '';
      _email = profile['email'] ?? email;
      _profilePicture = profile['profile_picture'] ?? '';
      _userId = profile['id'] ?? '';
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

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final profile = await _authService.getMe();
      _firstName = profile['first_name'] ?? '';
      _lastName = profile['last_name'] ?? '';
      _email = profile['email'] ?? '';
      _profilePicture = profile['profile_picture'] ?? '';
      _userId = profile['id'] ?? '';
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
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
    _email = "";
    _profilePicture = "";
    // Dans l'idéal, il faudrait appeler une route /logout pour vider le cookie HttpOnly
    notifyListeners();
  }

  Future<void> uploadProfilePicture(dynamic file) async {
    try {
      final newUrl = await _authService.uploadAvatar(file);
      _profilePicture = newUrl;
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de l'upload: $e");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.deleteAccount();
      logout();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = "Erreur lors de la suppression du compte";
      _setLoading(false);
      return false;
    }
  }
}

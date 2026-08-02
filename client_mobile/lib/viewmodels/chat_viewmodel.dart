

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../core/dio_client.dart';

class ChatMessage {
  final String role;
  final String text;

  ChatMessage({required this.role, required this.text});
}

class ChatViewModel extends ChangeNotifier {
  final DioClient _dioClient = DioClient();
  final List<ChatMessage> _messages = [
    ChatMessage(role: 'model', text: 'Bonjour ! Je suis Flyxy, votre assistant personnel. Comment puis-je vous aider pour vos trajets aujourd\'hui ?')
  ];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Ajouter le message de l'utilisateur localement
    _messages.add(ChatMessage(role: 'user', text: text));
    _isLoading = true;
    notifyListeners();

    try {
      double? lat;
      double? lon;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 3),
        );
        lat = position.latitude;
        lon = position.longitude;
      } catch (_) {
        // Ignorer si la position n'est pas disponible, l'API gèrera l'absence de coordonnées
      }

      // Préparer l'historique (exclure le message actuel et les erreurs)
      final historyList = _messages
          .where((m) => m != _messages.last && !m.text.startsWith('Erreur'))
          .map((m) => {
                'role': m.role,
                'parts': [{'text': m.text}]
              })
          .toList();

      final response = await _dioClient.dio.post(
        '/chat',
        data: {
          'message': text,
          'history': historyList,
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        },
      );

      final modelText = response.data['response'] ?? 'Désolé, je n\'ai pas compris.';
      _messages.add(ChatMessage(role: 'model', text: modelText));
    } catch (e) {
      // Gérer l'erreur proprement
      String errorMsg = 'Une erreur est survenue lors de la communication avec le serveur.';
      if (e.toString().contains('404')) {
         errorMsg = 'L\'API de chat n\'est pas disponible.';
      } else if (e is DioException && e.response != null) {
         errorMsg = 'Erreur IA: ${e.response?.data['error'] ?? e.toString()}';
      } else {
         errorMsg = 'Erreur réseau: veuillez réessayer. (${e.toString()})';
      }
      _messages.add(ChatMessage(role: 'model', text: errorMsg));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

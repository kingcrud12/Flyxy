

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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
      final response = await _dioClient.dio.post(
        '/chat',
        data: {'message': text},
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

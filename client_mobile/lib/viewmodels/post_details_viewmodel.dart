import 'package:flutter/foundation.dart';
import '../services/social_service.dart';

class PostDetailsViewModel extends ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<dynamic> _comments = [];
  List<dynamic> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _socialService.getComments(postId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createComment(String postId, String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _socialService.createComment(postId, text);
      await fetchComments(postId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    try {
      final isLiked = await _socialService.toggleCommentLike(commentId);
      
      final index = _comments.indexWhere((c) => c['id'] == commentId);
      if (index != -1) {
        _comments[index]['liked_by_me'] = isLiked;
        _comments[index]['likes'] += isLiked ? 1 : -1;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

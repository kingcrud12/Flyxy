import 'package:flutter/foundation.dart';
import '../services/social_service.dart';

class SocialViewModel extends ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<dynamic> _posts = [];
  List<dynamic> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _socialService.getPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String text, dynamic imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _socialService.createPost(text, imageFile);
      await fetchPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(String postId, String text) async {
    try {
      final updatedPost = await _socialService.updatePost(postId, text);
      final index = _posts.indexWhere((p) => p['id'] == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> togglePostLike(String postId) async {
    try {
      final isLiked = await _socialService.togglePostLike(postId);
      
      final index = _posts.indexWhere((p) => p['id'] == postId);
      if (index != -1) {
        _posts[index]['liked_by_me'] = isLiked;
        _posts[index]['likes'] += isLiked ? 1 : -1;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _socialService.deletePost(postId);
      _posts.removeWhere((p) => p['id'] == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

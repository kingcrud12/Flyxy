import 'package:dio/dio.dart';
import '../core/dio_client.dart';

class SocialService {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getPosts() async {
    final response = await _dio.get('posts');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> createPost(String text, dynamic imageFile) async {
    FormData formData = FormData.fromMap({
      "text": text,
    });
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      formData.files.add(
        MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
        ),
      );
    }
    
    final response = await _dio.post('posts', data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> updatePost(String postId, String text) async {
    final response = await _dio.put('posts/$postId', data: {'text': text});
    return response.data;
  }

  Future<bool> togglePostLike(String postId) async {
    final response = await _dio.post('posts/$postId/like');
    return response.data['liked'];
  }

  Future<List<dynamic>> getComments(String postId) async {
    final response = await _dio.get('posts/$postId/comments');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> createComment(String postId, String text) async {
    final response = await _dio.post('posts/$postId/comments', data: {'text': text});
    return response.data;
  }

  Future<bool> toggleCommentLike(String commentId) async {
    final response = await _dio.post('comments/$commentId/like');
    return response.data['liked'];
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete('posts/$postId');
  }
}

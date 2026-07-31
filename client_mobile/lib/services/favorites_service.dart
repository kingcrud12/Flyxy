import 'package:dio/dio.dart';
import '../core/dio_client.dart';

class FavoritesService {
  final Dio _dio = DioClient().dio;

  FavoritesService();

  Future<void> addFavoritePlace(String name, String stopAreaId, String iconName) async {
    try {
      await _dio.post('favorites/places', data: {
        'name': name,
        'stop_area_id': stopAreaId,
        'icon_name': iconName,
      });
    } catch (e) {
      throw Exception('Erreur ajout favori: $e');
    }
  }

  Future<List<dynamic>> getFavoritePlaces() async {
    try {
      final response = await _dio.get('favorites/places');
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur liste favoris: $e');
    }
  }

  Future<void> deleteFavoritePlace(String id) async {
    try {
      await _dio.delete('favorites/places/$id');
    } catch (e) {
      throw Exception('Erreur suppression favori: $e');
    }
  }

  Future<void> addFavoriteRoute(String name, String fromStopId, String toStopId) async {
    try {
      await _dio.post('favorites/routes', data: {
        'name': name,
        'from_stop_id': fromStopId,
        'to_stop_id': toStopId,
      });
    } catch (e) {
      throw Exception('Erreur ajout itinéraire favori: $e');
    }
  }

  Future<List<dynamic>> getFavoriteRoutes() async {
    try {
      final response = await _dio.get('favorites/routes');
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur liste itinéraires favoris: $e');
    }
  }

  Future<void> deleteFavoriteRoute(String id) async {
    try {
      await _dio.delete('favorites/routes/$id');
    } catch (e) {
      throw Exception('Erreur suppression itinéraire favori: $e');
    }
  }
}

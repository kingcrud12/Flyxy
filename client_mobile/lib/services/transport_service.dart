import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../models/departure.dart';

class TransportService {
  final Dio _dio = DioClient().dio;

  Future<List<Departure>> getNearbyDepartures(double lat, double lon) async {
    try {
      final response = await _dio.get('transports/nearby', queryParameters: {
        'lat': lat,
        'lon': lon,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Departure.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load departures');
      }
    } catch (e) {
      throw Exception('Erreur réseau ou API: $e');
    }
  }

  Future<List<dynamic>> getNearbyMapStops(double lat, double lon) async {
    try {
      final response = await _dio.get('transports/map/nearby', queryParameters: {
        'lat': lat,
        'lon': lon,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des arrêts pour la carte: $e');
    }
  }

  Future<Map<String, dynamic>> getVehicleJourney(String id) async {
    try {
      final response = await _dio.get('transports/vehicle-journey/$id');
      return response.data['data'] ?? {};
    } catch (e) {
      throw Exception('Erreur lors de la récupération des détails de la direction: $e');
    }
  }

  Future<List<dynamic>> searchPlaces(String query) async {
    try {
      final response = await _dio.get('transports/places', queryParameters: {'q': query});
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la recherche de lieux: $e');
    }
  }

  Future<List<dynamic>> getJourneysStr(String fromId, String toId) async {
    try {
      final response = await _dio.get('transports/journeys', queryParameters: {
        'from': fromId,
        'to': toId,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors du calcul de l\'itinéraire: $e');
    }
  }

  Future<List<dynamic>> getDisruptions(double lat, double lon) async {
    try {
      final response = await _dio.get('/transports/disruptions', queryParameters: {
        'lat': lat,
        'lon': lon,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des perturbations: $e');
    }
  }
}

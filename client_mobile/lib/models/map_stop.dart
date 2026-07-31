import 'departure.dart';

class MapStop {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final List<Departure> departures;

  MapStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.departures,
  });

  factory MapStop.fromJson(Map<String, dynamic> json) {
    return MapStop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      departures: (json['departures'] as List<dynamic>?)
              ?.map((d) => Departure.fromJson(d))
              .toList() ??
          [],
    );
  }
}

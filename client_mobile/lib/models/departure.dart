class Departure {
  final String line;
  final String type;
  final String color;
  final String textColor;
  final List<Direction> directions;
  final String? stopId;
  final double? lat;
  final double? lon;

  Departure({
    required this.line,
    required this.type,
    required this.color,
    required this.textColor,
    required this.directions,
    this.stopId,
    this.lat,
    this.lon,
  });

  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      line: json['line'] ?? '',
      type: json['type'] ?? '',
      color: json['color'] ?? 'FF000000',
      textColor: json['text_color'] ?? 'FFFFFFFF',
      stopId: json['stop_id'],
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lon: json['lon'] != null ? (json['lon'] as num).toDouble() : null,
      directions: (json['directions'] as List<dynamic>?)
              ?.map((d) => Direction.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class Direction {
  final String name;
  final List<String> times;
  final String? vehicleJourneyId;

  Direction({
    required this.name,
    required this.times,
    this.vehicleJourneyId,
  });

  factory Direction.fromJson(Map<String, dynamic> json) {
    return Direction(
      name: json['name'],
      times: List<String>.from(json['times']),
      vehicleJourneyId: json['vehicle_journey_id'],
    );
  }
}

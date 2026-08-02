import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/departure.dart';
import '../services/transport_service.dart';

class TransportViewModel extends ChangeNotifier {
  final TransportService _transportService = TransportService();
  Timer? _refreshTimer;

  List<Departure> _departures = [];
  List<Departure> get departures => _departures;

  List<dynamic> _disruptions = [];
  List<dynamic> get disruptions => _disruptions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  Future<void> fetchNearbyDepartures({bool silent = false}) async {
    if (!silent) _setLoading(true);
    _error = null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = "Les services de localisation sont désactivés.";
        _setLoading(false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = "Les permissions de localisation sont refusées.";
          _setLoading(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = "Permissions de localisation définitivement refusées.";
        _setLoading(false);
        return;
      }

      // On essaie d'abord d'obtenir la position actuelle réelle
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        // En cas de timeout ou d'erreur, on se rabat sur la dernière position connue
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        _error = "Impossible de récupérer votre position.";
        _setLoading(false);
        return;
      }
      
      _currentPosition = position;
      
      _departures = await _transportService.getNearbyDepartures(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!silent) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> fetchDisruptions() async {
    try {
      double lat = _currentPosition?.latitude ?? 0.0;
      double lon = _currentPosition?.longitude ?? 0.0;
      _disruptions = await _transportService.getDisruptions(lat, lon);
      notifyListeners();
    } catch (e) {
      print('Erreur fetchDisruptions: $e');
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNearbyDepartures(silent: true);
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  
  List<dynamic> _places = [];
  List<dynamic> _routes = [];
  bool _isLoading = false;

  List<dynamic> get places => _places;
  List<dynamic> get routes => _routes;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _places = await _favoritesService.getFavoritePlaces();
      _routes = await _favoritesService.getFavoriteRoutes();
    } catch (e) {
      debugPrint("Erreur lors du chargement des favoris: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavoritePlace(String name, String stopAreaId, String iconName) async {
    try {
      await _favoritesService.addFavoritePlace(name, stopAreaId, iconName);
      await loadFavorites(); // Re-fetch immediately to keep sync
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFavoritePlace(String id) async {
    try {
      await _favoritesService.deleteFavoritePlace(id);
      await loadFavorites();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFavoriteRoute(String name, String fromId, String toId) async {
    try {
      await _favoritesService.addFavoriteRoute(name, fromId, toId);
      await loadFavorites();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFavoriteRoute(String id) async {
    try {
      await _favoritesService.deleteFavoriteRoute(id);
      await loadFavorites();
    } catch (e) {
      rethrow;
    }
  }
}

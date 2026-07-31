import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../services/transport_service.dart';
import 'itinerary_results_view.dart';


class SavedViewScreen extends StatefulWidget {
  const SavedViewScreen({super.key});

  @override
  State<SavedViewScreen> createState() => _SavedViewScreenState();
}

class _SavedViewScreenState extends State<SavedViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load favorites immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthViewModel>().isAuthenticated) {
        context.read<FavoritesViewModel>().loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    if (context.read<AuthViewModel>().isAuthenticated) {
      await context.read<FavoritesViewModel>().loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final favorites = context.watch<FavoritesViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Favoris', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.place), text: 'Arrêts'),
            Tab(icon: Icon(Icons.directions), text: 'Itinéraires'),
          ],
        ),
      ),
      body: !auth.isAuthenticated
          ? const Center(
              child: Text(
                'Connectez-vous pour voir vos favoris',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: Colors.amber,
                  child: _buildPlacesList(favorites),
                ),
                RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: Colors.amber,
                  child: _buildRoutesList(favorites),
                ),
              ],
            ),
    );
  }

  Widget _buildPlacesList(FavoritesViewModel favorites) {
    if (favorites.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    if (favorites.places.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(child: Text('Aucun arrêt favori', style: TextStyle(color: Colors.white54))),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: favorites.places.length,
      itemBuilder: (context, index) {
        final place = favorites.places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GestureDetector(
                onTap: () async {
                  try {
                    final results = await TransportService().searchPlaces(place['name']);
                    if (results.isNotEmpty) {
                      final first = results.first;
                      double? lat;
                      double? lon;
                      if (first['lat'] != null && first['lon'] != null) {
                        lat = (first['lat'] as num).toDouble();
                        lon = (first['lon'] as num).toDouble();
                      }
                      if (context.mounted) {
                        context.go('/map', extra: {
                          'lat': lat,
                          'lon': lon,
                          'stopId': place['stop_area_id'],
                        });
                      }
                    } else {
                      if (context.mounted) {
                        context.go('/map', extra: {'stopId': place['stop_area_id']});
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.go('/map', extra: {'stopId': place['stop_area_id']});
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.star, color: Colors.black, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            place['name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF2C2C2E),
                                title: const Text('Supprimer le favori', style: TextStyle(color: Colors.white)),
                                content: const Text('Voulez-vous vraiment supprimer ce lieu favori ?', style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await context.read<FavoritesViewModel>().deleteFavoritePlace(place['id']);
                                      if (ctx.mounted) Navigator.pop(ctx);
                                    },
                                    child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutesList(FavoritesViewModel favorites) {
    if (favorites.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    if (favorites.routes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(child: Text('Aucun itinéraire favori', style: TextStyle(color: Colors.white54))),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: favorites.routes.length,
      itemBuilder: (context, index) {
        final route = favorites.routes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItineraryResultsView(
                      fromId: route['from_stop_id'] ?? '',
                      toId: route['to_stop_id'] ?? '',
                      toName: route['name'] ?? 'Itinéraire',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.directions, color: Colors.black, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          route['name'] ?? 'Itinéraire',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2E),
                              title: const Text('Supprimer le favori', style: TextStyle(color: Colors.white)),
                              content: const Text('Voulez-vous vraiment supprimer cet itinéraire favori ?', style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await context.read<FavoritesViewModel>().deleteFavoriteRoute(route['id']);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

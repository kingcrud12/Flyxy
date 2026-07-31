import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transport_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../services/transport_service.dart';
import '../widgets/liquid_background.dart';
import '../widgets/icon_picker_bottom_sheet.dart';
import 'map_view.dart';
import 'direction_details_view.dart';
import 'search_view.dart';
import '../models/departure.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TransportViewModel>();
      vm.fetchNearbyDepartures();
      vm.startAutoRefresh();
      
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  void dispose() {
    // Note: Le ViewModel est global via MultiProvider, il ne sera jamais disposé.
    // On pourrait arrêter le timer ici si nécessaire.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Laisse voir le fond du MainWrapper
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar & Map Icon Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) => const SearchViewScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: _GlassContainer(
                        height: 50,
                        borderRadius: 25,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: Colors.white70),
                            const SizedBox(width: 8),
                            const Text('Où allez-vous ?', style: TextStyle(color: Colors.white70)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.white70),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (context, _, __) => const SearchViewScreen(startListening: true),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icône Map avec Liquid Glass
                  GestureDetector(
                    onTap: () {
                      context.push('/map');
                    },
                    child: const _GlassContainer(
                      height: 50,
                      width: 50,
                      borderRadius: 25,
                      child: Icon(Icons.map, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Consumer<FavoritesViewModel>(
                builder: (context, favoritesVm, child) {
                  if (favoritesVm.places.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final topPlaces = favoritesVm.places.take(2).toList();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text('Favoris', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      Row(
                        children: topPlaces.map((place) {
                          final iconName = place['icon_name'] ?? 'Favori';
                          final iconData = IconPickerBottomSheet.icons[iconName] ?? Icons.star;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _FavoriteChip(
                              icon: iconData,
                              text: place['name'] ?? 'Lieu',
                              color: Colors.amber,
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
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Prochains départs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              // Glassmorphism Cards
              Expanded(
                child: Consumer<TransportViewModel>(
                  builder: (context, transportVm, child) {
                    if (transportVm.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (transportVm.error != null) {
                      return Center(
                        child: Text(
                          transportVm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (transportVm.departures.isEmpty) {
                      return const Center(
                        child: Text('Aucun transport à proximité', style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return ListView.separated(
                      itemCount: transportVm.departures.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= transportVm.departures.length) return const SizedBox.shrink();
                        final dep = transportVm.departures[index];

                        Color bgColor = Colors.grey;
                        Color textColor = Colors.white;
                        try {
                          if (dep.color.isNotEmpty) bgColor = Color(int.parse(dep.color, radix: 16));
                          if (dep.textColor.isNotEmpty) textColor = Color(int.parse(dep.textColor, radix: 16));
                        } catch (_) {}

                        return DepartureCard(
                          line: dep.line,
                          type: dep.type,
                          directions: dep.directions,
                          color: bgColor,
                          textColor: textColor,
                          onTap: () {
                            if (dep.stopId != null && dep.lat != null && dep.lon != null) {
                              context.go('/map', extra: {
                                'lat': dep.lat,
                                'lon': dep.lon,
                                'stopId': dep.stopId,
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget réutilisable pour l'effet Liquid Glass
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double borderRadius;

  const _GlassContainer({required this.child, this.height, this.width, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FavoriteChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;
  const _FavoriteChip({required this.icon, required this.text, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassContainer(
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartureCard extends StatelessWidget {
  final String line;
  final String type;
  final List<Direction> directions;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const DepartureCard({super.key, required this.line, required this.type, required this.directions, required this.color, this.textColor = Colors.white, this.onTap});

  Widget _buildLineBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        line,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTransportIcon() {
    if (type == 'Metro') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: const Text('M', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 4),
          _buildLineBadge(),
        ],
      );
    } else if (type == 'RER') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Text('RER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 4),
          _buildLineBadge(),
        ],
      );
    } else if (type == 'Tramway') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12),
            ),
            child: const Text('T', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 4),
          _buildLineBadge(),
        ],
      );
    } else {
      return _buildLineBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _GlassContainer(
        borderRadius: 16,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTransportIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: directions.map((dir) {
                  final time = dir.times.isNotEmpty ? dir.times.first : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (dir.vehicleJourneyId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DirectionDetailsScreen(
                                vehicleJourneyId: dir.vehicleJourneyId!,
                                directionName: dir.name,
                                color: color,
                                textColor: textColor,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              dir.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            time,
                            style: TextStyle(
                              color: color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

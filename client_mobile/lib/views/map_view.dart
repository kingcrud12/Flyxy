import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/map_stop.dart';
import '../services/transport_service.dart';
import 'home_view.dart' show DepartureCard;
import '../viewmodels/transport_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../widgets/liquid_background.dart';
import '../widgets/icon_picker_bottom_sheet.dart';
import '../services/favorites_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'dart:async';
import 'login_view.dart';

class MapViewScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String? initialStopId;

  const MapViewScreen({super.key, this.initialLat, this.initialLon, this.initialStopId});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  AppleMapController? mapController;
  MapController? androidMapController;
  Position? currentPosition;
  Set<Annotation> annotations = {};
  List<Marker> androidMarkers = [];
  List<MapStop> stops = [];
  bool isLoading = true;

  Timer? _trackingTimer;
  dynamic _trackedVehicleJourney;
  LatLng? _trackedVehicleLocation;
  ll.LatLng? _trackedAndroidLocation;
  String? _trackedVehicleJourneyId;
  Annotation? _trackedAnnotation;
  Marker? _trackedAndroidMarker;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initMap() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }

      double fetchLat = widget.initialLat ?? position.latitude;
      double fetchLon = widget.initialLon ?? position.longitude;

      // Fetch stops
      final rawStops = await TransportService().getNearbyMapStops(fetchLat, fetchLon);
      final parsedStops = rawStops.map((s) => MapStop.fromJson(s)).toList();

      if (mounted) {
        setState(() {
          stops = parsedStops;
          _buildAnnotations();
          isLoading = false;
        });
        
        if (widget.initialStopId != null) {
          try {
            final stop = stops.firstWhere((s) => s.id == widget.initialStopId);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _showStopDetails(stop);
            });
          } catch (e) {
            // Stop not found in nearby stops
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle error gently
    }
  }

  void _buildAnnotations() {
    annotations.clear();
    androidMarkers.clear();
    for (var stop in stops) {
      annotations.add(Annotation(
        annotationId: AnnotationId(stop.id),
        position: LatLng(stop.lat, stop.lon),
        infoWindow: InfoWindow(
          title: stop.name,
        ),
        onTap: () {
          _showStopDetails(stop);
        },
      ));

      androidMarkers.add(
        Marker(
          point: ll.LatLng(stop.lat, stop.lon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showStopDetails(stop),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ),
        ),
      );
    }
    
    if (_trackedAnnotation != null) {
      annotations.add(_trackedAnnotation!);
    }
    if (_trackedAndroidMarker != null) {
      androidMarkers.add(_trackedAndroidMarker!);
    }
  }

  void _startTracking(String vehicleJourneyId) async {
    try {
      final vj = await TransportService().getVehicleJourney(vehicleJourneyId);
      if (mounted) {
        setState(() {
          _trackedVehicleJourney = vj;
          _trackedVehicleJourneyId = vehicleJourneyId;
        });
        _updateTrackedPosition();
        _trackingTimer?.cancel();
        _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _updateTrackedPosition();
        });
        Navigator.pop(context); // Close the bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible de suivre ce transport")));
      }
    }
  }

  void _updateTrackedPosition() {
    if (_trackedVehicleJourney == null || _trackedVehicleJourney['stop_times'] == null) return;
    
    final stopTimes = _trackedVehicleJourney['stop_times'] as List<dynamic>;
    if (stopTimes.isEmpty) return;

    final now = DateTime.now();
    // Simulation: since times are usually HH:MM, we'll parse them and interpolate.
    // However, if the transport is already finished or hasn't started, we'll just snap to start/end.
    
    DateTime parseTime(String timeStr) {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      }
      return now;
    }

    LatLng? newPos;
    
    for (int i = 0; i < stopTimes.length - 1; i++) {
      final st1 = stopTimes[i];
      final st2 = stopTimes[i+1];
      
      final t1 = parseTime(st1['time']);
      final t2 = parseTime(st2['time']);
      
      if (now.isAfter(t1) && now.isBefore(t2)) {
        // Interpolate
        final totalDuration = t2.difference(t1).inSeconds;
        final elapsed = now.difference(t1).inSeconds;
        final progress = totalDuration > 0 ? elapsed / totalDuration : 0.0;
        
        final lat1 = st1['lat'] as double?;
        final lon1 = st1['lon'] as double?;
        final lat2 = st2['lat'] as double?;
        final lon2 = st2['lon'] as double?;
        
        if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
          final lat = lat1 + (lat2 - lat1) * progress;
          final lon = lon1 + (lon2 - lon1) * progress;
          newPos = LatLng(lat, lon);
        }
        break;
      } else if (now.isBefore(t1) && i == 0) {
        // Before start
        if (st1['lat'] != null && st1['lon'] != null) {
          newPos = LatLng(st1['lat'], st1['lon']);
        }
      } else if (now.isAfter(t2) && i == stopTimes.length - 2) {
        // After end
        if (st2['lat'] != null && st2['lon'] != null) {
          newPos = LatLng(st2['lat'], st2['lon']);
        }
      }
    }

    if (newPos != null && mounted) {
      setState(() {
        _trackedVehicleLocation = newPos;
        _trackedAndroidLocation = ll.LatLng(newPos!.latitude, newPos!.longitude);
        _trackedAnnotation = Annotation(
          annotationId: AnnotationId(_trackedVehicleJourneyId!),
          position: newPos!,
          icon: BitmapDescriptor.defaultAnnotation,
          infoWindow: InfoWindow(title: "Véhicule en direct"),
        );
        _trackedAndroidMarker = Marker(
          point: _trackedAndroidLocation!,
          width: 40,
          height: 40,
          child: const Icon(Icons.directions_bus, color: Colors.red, size: 40),
        );
        _buildAnnotations();
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(newPos!));
      androidMapController?.move(_trackedAndroidLocation!, 16.0);
    }
  }

  void _showStopDetails(MapStop stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E), // Dark theme modal
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          stop.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Consumer<FavoritesViewModel>(
                        builder: (context, favoritesVm, child) {
                          final isFavorite = favoritesVm.places.any((p) => p['stop_area_id'] == stop.id);
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: isFavorite ? Colors.amber : Colors.white,
                            ),
                            onPressed: () async {
                              if (isFavorite) {
                                final fav = favoritesVm.places.firstWhere((p) => p['stop_area_id'] == stop.id);
                                await favoritesVm.deleteFavoritePlace(fav['id']);
                              } else {
                                final authVm = context.read<AuthViewModel>();
                                if (!authVm.isAuthenticated) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: const Color(0xFF2C2C2E),
                                      title: const Text('Connexion requise', style: TextStyle(color: Colors.white)),
                                      content: const Text('Vous devez être connecté pour ajouter des favoris.', style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                                          },
                                          child: const Text('Se connecter', style: TextStyle(color: Colors.blueAccent)),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => IconPickerBottomSheet(
                                    onIconSelected: (iconName) async {
                                      try {
                                        await favoritesVm.addFavoritePlace(stop.name, stop.id, iconName);
                                        if (ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                        if (context.mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (ctx2) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(24),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.5),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Icon(Icons.favorite, color: Colors.redAccent, size: 64),
                                                        const SizedBox(height: 16),
                                                        const Text('Favori ajouté', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                                        const SizedBox(height: 8),
                                                        const Text('L\'arrêt a été ajouté à vos favoris avec succès.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                                                        const SizedBox(height: 24),
                                                        SizedBox(
                                                          width: double.infinity,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                                                            onPressed: () => Navigator.pop(ctx2),
                                                            child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...stop.departures.map((dep) {
                    Color bgColor = Colors.grey;
                    Color textColor = Colors.white;
                    try {
                      if (dep.color.isNotEmpty) bgColor = Color(int.parse(dep.color, radix: 16));
                      if (dep.textColor.isNotEmpty) textColor = Color(int.parse(dep.textColor, radix: 16));
                    } catch (_) {}

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: DepartureCard(
                        line: dep.line,
                        type: dep.type,
                        directions: dep.directions,
                        color: bgColor,
                        textColor: textColor,
                      ),
                    );
                  }).toList(),
                  // Feature in evolution: Suivre le transport en temps réel
                  /*
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Collect all directions
                          final List<Map<String, dynamic>> allDirections = [];
                          for (var dep in stop.departures) {
                            for (var dir in dep.directions) {
                              if (dir.vehicleJourneyId != null) {
                                allDirections.add({
                                  'name': dir.name,
                                  'line': dep.line,
                                  'vjId': dir.vehicleJourneyId,
                                });
                              }
                            }
                          }

                          if (allDirections.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun transport en temps réel disponible")));
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2E),
                              title: const Text('Suivre une direction', style: TextStyle(color: Colors.white)),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: allDirections.length,
                                  itemBuilder: (context, index) {
                                    final d = allDirections[index];
                                    return ListTile(
                                      title: Text('${d['line']} - ${d['name']}', style: const TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _startTracking(d['vjId']);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Suivre le transport en temps réel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                  */
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : (Platform.isIOS
              ? AppleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.initialLat ?? currentPosition!.latitude, 
                      widget.initialLon ?? currentPosition!.longitude,
                    ),
                    zoom: widget.initialLat != null ? 16 : 15,
                  ),
                  onMapCreated: (AppleMapController controller) {
                    mapController = controller;
                  },
                  annotations: annotations,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                )
              : FlutterMap(
                  mapController: androidMapController = MapController(),
                  options: MapOptions(
                    initialCenter: ll.LatLng(
                      widget.initialLat ?? currentPosition!.latitude, 
                      widget.initialLon ?? currentPosition!.longitude,
                    ),
                    initialZoom: widget.initialLat != null ? 16.0 : 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.flyxy.app',
                    ),
                    MarkerLayer(
                      markers: androidMarkers,
                    ),
                  ],
                )),
    );
  }
}

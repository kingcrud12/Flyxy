import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../services/transport_service.dart';
import 'dart:io';
import 'itinerary_results_view.dart';

class AccountView extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final VoidCallback onLogout;

  const AccountView({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.onLogout,
  });

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _isUploading = true;
        });
        
        final authViewModel = context.read<AuthViewModel>();
        await authViewModel.uploadProfilePicture(File(image.path));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour !')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final profilePic = authViewModel.profilePicture;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mon Compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: widget.onLogout),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // User Profile Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickAndUploadImage(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.amber,
                            backgroundImage: profilePic.isNotEmpty
                                ? NetworkImage(profilePic)
                                : null,
                            child: profilePic.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.black)
                                : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(color: Colors.white),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${widget.firstName} ${widget.lastName}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email,
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Favorites Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Lieux Favoris', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Consumer<FavoritesViewModel>(
                builder: (context, favoritesVm, child) {
                  if (favoritesVm.isLoading) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (favoritesVm.places.isEmpty) {
                    return const Text('Aucun lieu favori', style: TextStyle(color: Colors.white70));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoritesVm.places.length,
                    itemBuilder: (context, index) {
                      final place = favoritesVm.places[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: ListTile(
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
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: Text(place['name'] ?? '', style: const TextStyle(color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white54),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Supprimer le favori', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            const Text('Voulez-vous vraiment supprimer ce lieu favori ?', style: TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 24),
                                            Wrap(
                                              alignment: WrapAlignment.end,
                                              spacing: 8,
                                              children: [
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
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Itinéraires Favoris', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Consumer<FavoritesViewModel>(
                builder: (context, favoritesVm, child) {
                  if (favoritesVm.isLoading) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (favoritesVm.routes.isEmpty) {
                    return const Text('Aucun itinéraire favori', style: TextStyle(color: Colors.white70));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoritesVm.routes.length,
                    itemBuilder: (context, index) {
                      final route = favoritesVm.routes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: ListTile(
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
                          leading: const Icon(Icons.directions, color: Colors.blueAccent),
                          title: Text(route['name'] ?? '', style: const TextStyle(color: Colors.white)),
                          subtitle: const Text('Itinéraire favori', style: TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white54),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Supprimer le favori', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            const Text('Voulez-vous vraiment supprimer cet itinéraire favori ?', style: TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 24),
                                            Wrap(
                                              alignment: WrapAlignment.end,
                                              spacing: 8,
                                              children: [
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
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Légal Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Légal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ListTile(
                  onTap: () async {
                    final url = Uri.parse('https://flyxy.fr/politique-confidentialite');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  leading: const Icon(Icons.privacy_tip, color: Colors.blueAccent),
                  title: const Text('Voir la politique de confidentialité', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ListTile(
                  onTap: () async {
                    final url = Uri.parse('https://flyxy.fr/mentions-legales');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  leading: const Icon(Icons.gavel, color: Colors.orangeAccent),
                  title: const Text('Voir les mentions légales', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Danger Zone
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Danger', style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Supprimer mon compte', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible et toutes vos données (posts, favoris...) seront définitivement effacées.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 24),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.centerLeft,
                                        ),
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Annuler', style: TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.centerLeft,
                                        ),
                                        onPressed: () async {
                                          final authVm = context.read<AuthViewModel>();
                                          final success = await authVm.deleteAccount();
                                          if (success && ctx.mounted) {
                                            Navigator.pop(ctx);
                                            context.go('/login');
                                          } else if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Erreur lors de la suppression')),
                                            );
                                          }
                                        },
                                        child: const Text('Supprimer définitivement', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Supprimer mon compte', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
    );
  }
}

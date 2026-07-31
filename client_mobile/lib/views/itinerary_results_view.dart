import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/transport_service.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';

class ItineraryResultsView extends StatefulWidget {
  final String fromId;
  final String toId;
  final String toName;

  const ItineraryResultsView({
    super.key,
    required this.fromId,
    required this.toId,
    required this.toName,
  });

  @override
  State<ItineraryResultsView> createState() => _ItineraryResultsViewState();
}

class _ItineraryResultsViewState extends State<ItineraryResultsView> {
  final TransportService _transportService = TransportService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _journeys = [];
  Map<String, dynamic>? _selectedJourney;

  @override
  void initState() {
    super.initState();
    _fetchJourney();
  }

  Future<void> _fetchJourney() async {
    try {
      final response = await _transportService.getJourneysStr(widget.fromId, widget.toId);
      setState(() {
        _journeys = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    if (mins < 60) return '$mins min';
    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    return '${hours}h${remainingMins.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Liquid Glass Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_selectedJourney != null) {
                        setState(() {
                          _selectedJourney = null;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text('Vers ${widget.toName}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () async {
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

                        try {
                          await context.read<FavoritesViewModel>().addFavoriteRoute(
                            'Vers ${widget.toName}',
                            widget.fromId,
                            widget.toId,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Itinéraire ajouté aux favoris !')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center),
                              ),
                            )
                          : _journeys.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.directions_off, size: 48, color: Colors.white54),
                                        SizedBox(height: 16),
                                        Text(
                                          'Itinéraire indisponible\n(ex: service non disponible à cette heure)',
                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _selectedJourney != null
                                  ? _buildJourneyDetails(_selectedJourney!)
                                  : _buildJourneysList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneysList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _journeys.length,
      itemBuilder: (context, index) {
        final journey = _journeys[index];
        final duration = journey['duration'] as int;
        final transfers = journey['nb_transfers'] as int;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedJourney = journey;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.directions, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Durée: ${_formatDuration(duration)}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transfers == 0 ? 'Trajet direct' : '$transfers correspondance(s)',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJourneyDetails(Map<String, dynamic> journey) {
    final duration = journey['duration'] as int;
    final sections = journey['sections'] as List<dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temps de trajet: ${_formatDuration(duration)}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ...sections.map((sec) {
                    final colorStr = sec['color'] ?? '0xFFFFFFFF';
                    final color = Color(int.parse(colorStr));
                    final textColorStr = sec['text_color'] ?? '0xFF000000';
                    final textColor = Color(int.parse(textColorStr));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Icon(
                                sec['mode'] == 'walking' ? Icons.directions_walk : Icons.directions_transit,
                                color: color,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 2,
                                height: 40,
                                color: color.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (sec['line'] != null && sec['line'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sec['line'],
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  sec['from_name'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Vers ${sec['to_name']} (${_formatDuration(sec['duration'])})',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

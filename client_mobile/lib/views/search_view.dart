import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/transport_service.dart';
import 'itinerary_results_view.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchViewScreen extends StatefulWidget {
  final bool startListening;
  const SearchViewScreen({super.key, this.startListening = false});

  @override
  State<SearchViewScreen> createState() => _SearchViewScreenState();
}

class _SearchViewScreenState extends State<SearchViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TransportService _transportService = TransportService();
  
  List<dynamic> _results = [];
  bool _isLoading = false;
  Position? _currentPosition;
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  Timer? _silenceTimer;

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speechToText.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    if (widget.startListening) {
      // Small delay to allow transition before popping up mic permission
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _listen();
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) {}
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
              if (_searchController.text.isNotEmpty) {
                _autoSearchAndSelect(_searchController.text);
              }
            }
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        
        // Initial timer: if the user says nothing at all for 4 seconds, we stop.
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 4), () {
          if (_isListening) {
            _speechToText.stop();
          }
        });

        _speechToText.listen(
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
            });
            if (val.finalResult) {
              if (_isListening) {
                _speechToText.stop();
              }
            } else {
              _silenceTimer?.cancel();
              _silenceTimer = Timer(const Duration(seconds: 2), () {
                if (_isListening) {
                  _speechToText.stop();
                }
              });
            }
          },
          localeId: 'fr_FR',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
      if (_searchController.text.isNotEmpty) {
        _autoSearchAndSelect(_searchController.text);
      }
    }
  }

  void _autoSearchAndSelect(String query) async {
    if (query.length < 3) return;

    setState(() => _isLoading = true);
    try {
      final results = await _transportService.searchPlaces(query);
      if (results.isNotEmpty && mounted) {
        // Automatically select the first match
        _selectPlace(results.first);
        // Reset loading state just in case we return to this screen
        setState(() => _isLoading = false);
      } else if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _transportService.searchPlaces(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _selectPlace(dynamic place) {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation non disponible')),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => ItineraryResultsView(
          fromId: '${_currentPosition!.longitude};${_currentPosition!.latitude}',
          toId: place['id'],
          toName: place['name'],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
                  title: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (_results.isNotEmpty) {
                        _selectPlace(_results.first);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Où allez-vous ?',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _results = []);
                              },
                            ),
                          IconButton(
                            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.white70),
                            onPressed: _listen,
                          ),
                        ],
                      ),
                    ),
                    onChanged: _onSearchChanged,
                    autofocus: true,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1),
                    itemBuilder: (context, index) {
                      final place = _results[index];
                      IconData icon = Icons.place;
                      if (place['type'] == 'stop_area') icon = Icons.directions_bus;
                      
                      return ListTile(
                        leading: Icon(icon, color: Colors.white),
                        title: Text(place['name'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(place['type'], style: const TextStyle(color: Colors.white54)),
                        onTap: () => _selectPlace(place),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

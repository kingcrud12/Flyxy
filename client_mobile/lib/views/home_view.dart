import 'dart:ui';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
                    child: _GlassContainer(
                      height: 50,
                      borderRadius: 25,
                      child: const Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.white70),
                          SizedBox(width: 8),
                          Text('Search stations or routes...', style: TextStyle(color: Colors.white70)),
                          Spacer(),
                          Icon(Icons.mic, color: Colors.white70),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icône Map avec Liquid Glass
                  _GlassContainer(
                    height: 50,
                    width: 50,
                    borderRadius: 25,
                    child: const Icon(Icons.map, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Favorites', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              // Favorites chips
              const Row(
                children: [
                  _FavoriteChip(icon: Icons.star, text: 'Gare du Nord', color: Colors.amber),
                  SizedBox(width: 8),
                  _FavoriteChip(icon: Icons.account_balance, text: 'Châtelet', color: Colors.white),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Next Departures', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              // Glassmorphism Cards
              Expanded(
                child: ListView(
                  children: const [
                    _DepartureCard(line: 'A', type: 'RER', direction: 'Marne-la-Vallée', to: 'Cergy-le-Haut', time1: '2 min', time2: '8 min', color: Color(0xFFE3293B), textColor: Colors.white),
                    SizedBox(height: 12),
                    _DepartureCard(line: '1', type: 'Metro', direction: 'La Défense', to: 'Nation', time1: '5 min', time2: '9 min', color: Color(0xFFFFCE00), textColor: Colors.black),
                  ],
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
  const _FavoriteChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
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
    );
  }
}

class _DepartureCard extends StatelessWidget {
  final String line;
  final String type;
  final String direction;
  final String to;
  final String time1;
  final String time2;
  final Color color;
  final Color textColor;

  const _DepartureCard({required this.line, required this.type, required this.direction, required this.to, required this.time1, required this.time2, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: color, radius: 16, child: Text(line, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Direction: $direction', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('to $to', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time1, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(time2, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

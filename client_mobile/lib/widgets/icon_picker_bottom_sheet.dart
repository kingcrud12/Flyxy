import 'dart:ui';
import 'package:flutter/material.dart';

class IconPickerBottomSheet extends StatelessWidget {
  final Function(String) onIconSelected;

  const IconPickerBottomSheet({super.key, required this.onIconSelected});

  static const Map<String, IconData> icons = {
    'Maison': Icons.home,
    'Travail': Icons.work,
    'Gare': Icons.train,
    'École': Icons.school,
    'Sport': Icons.sports_basketball,
    'Restaurant': Icons.restaurant,
    'Santé': Icons.local_hospital,
    'Favori': Icons.star,
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisir une icône',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: icons.entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      onIconSelected(entry.key);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Icon(entry.value, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

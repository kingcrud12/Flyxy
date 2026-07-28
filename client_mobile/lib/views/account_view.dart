import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  final String firstName;
  final String lastName;
  final VoidCallback onLogout;

  const AccountView({super.key, required this.firstName, required this.lastName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mon Compte'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text('$firstName $lastName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 32),
            const Text('Lieux favoris', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Card(
              color: Colors.white12,
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.amber),
                title: const Text('Maison'),
                subtitle: const Text('Gare du Nord'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Itinéraires favoris', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Card(
              color: Colors.white12,
              child: ListTile(
                leading: const Icon(Icons.directions_transit, color: Colors.blueAccent),
                title: const Text('Travail'),
                subtitle: const Text('Châtelet -> La Défense'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

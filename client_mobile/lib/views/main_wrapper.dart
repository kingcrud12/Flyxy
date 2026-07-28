import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainWrapper({super.key, required this.navigationShell});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentBgIndex = 0;
  final List<String> _backgrounds = [
    'assets/bg.jpg',
    'assets/bg2.jpg',
    'assets/bg3.jpg',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentBgIndex = (_currentBgIndex + 1) % _backgrounds.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(seconds: 2),
            child: Container(
              key: ValueKey<int>(_currentBgIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgrounds[_currentBgIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          widget.navigationShell,
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            color: Colors.black.withOpacity(0.3), // Liquid glass
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent, // Transparent pour voir le glass
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (index) {
                // Seulement si on a géré les routes dans les branches
                if (index == 0 || index == 3) {
                  widget.navigationShell.goBranch(
                    index == 0 ? 0 : 1,
                    initialLocation: index == widget.navigationShell.currentIndex,
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

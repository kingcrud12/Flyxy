import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'chat_modal.dart';

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
    final String location = GoRouterState.of(context).uri.path;
    final bool isMap = location.contains('/map');
    
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
              child: const ChatModal(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        elevation: 8,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: isMap ? 0.85 : 0.4),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent, // Transparent pour voir le glass
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              currentIndex: widget.navigationShell.currentIndex,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
                BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Communauté'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

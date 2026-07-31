import 'package:flutter/material.dart';

class LiquidBackground extends StatelessWidget {
  const LiquidBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

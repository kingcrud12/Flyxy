import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep dark background
    primaryColor: Colors.amber, // Accent color for stars
    colorScheme: const ColorScheme.dark(
      primary: Colors.amber,
      secondary: Colors.blueAccent,
      surface: Color(0xFF1E1E1E), // Slightly lighter for glassmorphism panels
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFF06B6D4);
  static const Color _secondaryColor = Color(0xFFF59E0B);
  static const Color _surfaceColor = Color(0xFF161616);
  static const Color _backgroundColor = Color(0xFF0D0D0D);
  static const Color _cardColor = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  static List<Color> get gradientColors => [
    const Color(0xFF06B6D4),
    const Color(0xFFF59E0B),
  ];

  static List<Color> get backgroundGradient => [
    const Color(0xFF0D0D0D),
    const Color(0xFF1A1A1A),
  ];
}

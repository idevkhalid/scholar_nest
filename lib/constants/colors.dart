import 'package:flutter/material.dart';

class AppColors {
  // Main color used in theme
  static const Color primary = Color(0xFF1B3C53);

  // Background fallback color
  static const Color background = Color(0xFFEAF1F8);

  // Text colors
  static const Color textPrimary = Color(0xFF1B3C53);
  static const Color textSecondary = Color(0xFF7B7B7B);

  // Card background
  static const Color cardBackground = Colors.white;

  // Success & error colors
  static const Color error = Colors.red;
  static const Color success = Colors.green;

  // Gradient Top/Bottom raw color values
  static const Color gradientTop = Color(0x6677A9FF); // 40% transparent
  static const Color gradientBottom = Colors.white;

  // FINAL background gradient (exact like your sample)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x9977A9FF),

      Colors.white,      // white at bottom
    ],
  );

  // Primary gradient (if needed for buttons)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1B3C53),
      Color(0xFF1B3C53),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color? get secondary => null;

  static Color? get tileBackground => null;
}

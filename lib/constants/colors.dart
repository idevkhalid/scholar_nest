import 'package:flutter/material.dart';

class AppColors {
  // Primary color for buttons, headers, and highlights
  static const Color primary = Color(0xFF1B3C53);

  // Scaffold or screen background
  static const Color background = Color(0xFFEAF1F8);

  // Optional gradient for screens or headers
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFB9D6F2), Color(0xFFEAF1F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors
  static const Color textPrimary = Color(0xFF1B3C53); // dark text
  static const Color textSecondary = Color(0xFF7B7B7B); // gray text

  // Card or container background
  static const Color cardBackground = Colors.white;

  // Optional for special purposes
  static const Color error = Colors.red;
  static const Color success = Colors.green;

  static const Color? tileBackground = null;

static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF1B3C53), Color(0xFF1B3C53)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

  static Color? get secondary => null;
}

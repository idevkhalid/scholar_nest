import 'package:flutter/material.dart';

class AppColors {
  // ================= MODERN LUXURY PALETTE (Your Selection) =================

  // PRIMARY: A deep, rich "Petrol" Teal. Unique, serious, and premium.
  static const Color primary = Color(0xFF004D40);

  // SECONDARY: A muted "Antique Gold" for buttons/icons.
  static const Color secondary = Color(0xFFD4AF37);

  // BACKGROUND: "Porcelain" - A very subtle warm white.
  static const Color background = Color(0xFFFAFAFA);

  // ================= DARK THEME (ELEGANT CHARCOAL) =================
  static const Color backgroundDark = Color(0xFF121212); // True Black/Grey
  static const Color cardDark = Color(0xFF1E1E1E);       // Dark Grey Surface
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);

  // ================= TEXT COLORS (Light Mode) =================
  static const Color textPrimary = Color(0xFF263238);  // Deep Blue-Grey
  static const Color textSecondary = Color(0xFF546E7A); // Soft Grey
  static const Color textLight = Color(0xFFB0BEC5);

  // ================= SURFACE =================
  static const Color cardBackground = Colors.white;
  static const Color glassBorder = Color(0x33FFFFFF); // Useful for glassmorphism overlays

  // ================= STATUS =================
  static const Color success = Color(0xFF2E7D32); // Forest Green
  static const Color error = Color(0xFFC62828);   // Brick Red
  static const Color warning = Color(0xFFEF6C00); // Burnt Orange

  // ================= PREMIUM GRADIENTS =================

  // ✅ NEW: Header Gradient (Use this for the App Bar background)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0xFF004D40), // Deep Teal
      Color(0xFF00695C), // Slightly Lighter Teal
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 1. Primary Gradient (Diagonal)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF004D40), // Deep Teal
      Color(0xFF00695C), // Lighter Teal
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 2. Background Gradient (Subtle)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F5F5),
    ],
  );

  // 3. Accent Gradient (Gold)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFFFC107),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 4. Dark Mode Background
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212),
      Color(0xFF000000),
    ],
  );
}
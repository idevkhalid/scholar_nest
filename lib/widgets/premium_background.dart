import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Check if Dark Mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Switch Gradients based on theme
        gradient: isDark
            ? AppColors.darkBackgroundGradient
            : AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Optional: Add a subtle glow in the background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.primary.withOpacity(0.15) // Subtle Blue Glow in Dark Mode
                    : Colors.white.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.primary.withOpacity(0.2) : Colors.white,
                    blurRadius: 90,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
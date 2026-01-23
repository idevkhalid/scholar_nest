import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import '../constants/colors.dart';
import '../widgets/modern_button.dart';

class VerifiedScreen extends StatelessWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient, // gradient background
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Success Icon Circle with gradient ---
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 110,
                  ),
                ),

                const SizedBox(height: 30),

                // --- Heading ---
                Text(
                  "Verified Successfully!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.literata(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 12),

                // --- Sub Text ---
                Text(
                  "Your account has been verified.\nWelcome to Scholar Nest!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.literata(
                    fontSize: 16,
                    color: AppColors.textSecondary?.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 40),

                // --- Continue Button with gradient ---
                ModernButton(
                  text: "Continue",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Required for logic
import '../constants/colors.dart';
import 'intro_screen.dart';
import 'walk_through_screen.dart'; // Import the walkthrough screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------------
    // 1. ANIMATION SETUP (Your original code)
    // ----------------------------------------------------------------
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fade = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    // ----------------------------------------------------------------
    // 2. NAVIGATION LOGIC
    // ----------------------------------------------------------------
    _navigateBasedOnUserStatus();
  }

  Future<void> _navigateBasedOnUserStatus() async {
    // A. Wait for 2 seconds (so user sees the logo animation)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // B. Check local storage
    final prefs = await SharedPreferences.getInstance();
    final bool seenWalkthrough = prefs.getBool('seenWalkthrough') ?? false;

    // C. Decide where to go
    if (seenWalkthrough) {
      // User has already seen the walkthrough -> Go to Intro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    } else {
      // First time user -> Go to Walkthrough
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: width * 0.50,
                  height: width * 0.50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applovin_max/applovin_max.dart'; // ✅ Import AppLovin

// --- IMPORTS ---
import '../constants/colors.dart';
import '../services/api_service.dart'; // ✅ Import API Service
import '../services/ad_service.dart';  // ✅ Import Ad Service

// Screens
import 'intro_screen.dart';
import 'walk_through_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Set status bar to transparent for immersive feel
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _initAnimations();
    _initializeApp(); // ✅ Calls the new combined logic
  }

  void _initAnimations() {
    _mainController = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this
    );

    // 1. Logo Pop-up (Elastic)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Text Slide Up
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
  }

  // ✅ NEW: Merged Logic (Animations + Data Loading)
  Future<void> _initializeApp() async {
    // 1. Start a timer to ensure animations are seen (Minimum 3.5s)
    final minDisplayTime = Future.delayed(const Duration(milliseconds: 3500));

    // 2. Load External Services in Background (Ads & API)
    // We don't await this strictly so it doesn't block if it's slow,
    // but we start it now so it's ready when the user reaches Home.
    _loadExternalData();

    // 3. Wait for the animation/timer to finish
    await minDisplayTime;

    if (!mounted) return;

    // 4. Check Navigation Status
    final prefs = await SharedPreferences.getInstance();
    final bool seenWalkthrough = prefs.getBool('seenWalkthrough') ?? false;

    // 5. Navigate
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => seenWalkthrough ? const IntroScreen() : const WalkthroughScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  // ✅ Helper to load Ads & Settings
  Future<void> _loadExternalData() async {
    try {
      // A. Initialize AppLovin SDK
      // Replace with your actual key if needed, or keep generic if managed elsewhere
      await AppLovinMAX.initialize("«sdk-key»");

      // B. Fetch Ad Unit IDs from your API
      final response = await ApiService.getPublicSettings();

      if (response['success'] == true && response['data'] != null) {
        String adUnitId = response['data']['interstitial_ad_unit_id'] ?? "";

        if (adUnitId.isNotEmpty) {
          AdService().initialize(adUnitId);
          debugPrint("✅ [Splash] Ad Service Initialized with ID: $adUnitId");
        }
      }
    } catch (e) {
      debugPrint("❌ [Splash] Initialization Warning: $e");
      // App continues even if this fails
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // Interactive Background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Background Blobs (Decoration) ---
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(color: AppColors.secondary.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 80, spreadRadius: 10)
                  ],
                ),
              ),
            ),

            // --- Main Content ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Container(
                      padding: const EdgeInsets.all(4), // Border width
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Gradient Border
                        gradient: AppColors.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(25), // Inner Padding
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpeg',
                            width: width * 0.25,
                            height: width * 0.25,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 2. Text Branding
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Scholar",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: "Nest",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Your Gateway to Global Education",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- Footer Loading ---
            Positioned(
              bottom: 60,
              child: FadeTransition(
                opacity: _textFade,
                child: const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
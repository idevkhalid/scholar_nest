import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:applovin_max/applovin_max.dart';

import 'services/api_service.dart';
import 'services/ad_service.dart';

import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/filter_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize AppLovin SDK (Replace with your actual SDK Key)
  await AppLovinMAX.initialize("«sdk-key»");

  // 2. Fetch Settings from API
  try {
    final response = await ApiService.getPublicSettings();

    if (response['success'] == true && response['data'] != null) {

      // TODO: When backend gives the key, replace 'interstitial_ad_unit_id' below
      String adUnitId = response['data']['interstitial_ad_unit_id'] ?? "";

      if (adUnitId.isNotEmpty) {
        AdService().initialize(adUnitId);
      } else {
        print("⚠️ [Main] Ad Unit ID is empty. Ads will not show.");
      }
    }
  } catch (e) {
    print("❌ [Main] Error fetching settings: $e");
  }

  runApp(const ScholarNestApp());
}

class ScholarNestApp extends StatelessWidget {
  const ScholarNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scholar_Nest',
        theme: ThemeData(
          primaryColor: const Color(0xFF1B3C53),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: GoogleFonts.literata().fontFamily,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3C53),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
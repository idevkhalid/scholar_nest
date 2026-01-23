import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/theme_provider.dart';
import 'constants/colors.dart';// ✅ Ensures the new Luxury colors are loaded

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScholarNestApp());
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("YOUR_APP_ID");
  OneSignal.Notifications.requestPermission(true);
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Scholar Nest',

            // Listen to the Theme Provider
            themeMode: themeProvider.themeMode,

            // ================= LIGHT THEME (Modern Luxury) =================
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,

              // Base Colors
              scaffoldBackgroundColor: AppColors.background, // Porcelain
              primaryColor: AppColors.primary, // Deep Teal
              cardColor: Colors.white,
              dividerColor: Colors.grey.withOpacity(0.2),

              // Color Scheme (The Engine)
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary, // Antique Gold
                surface: AppColors.background,
                brightness: Brightness.light,
              ),

              // Typography
              fontFamily: GoogleFonts.poppins().fontFamily,
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.primary,
              ),

              // ✅ MERGED HEADER: Solid Teal Background + White Text
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary, // Deep Teal background
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white), // White Icons (Back arrow, hamburger)
                actionsIconTheme: IconThemeData(color: AppColors.secondary), // Gold Icons (Filters, etc)
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              // Buttons
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Teal Button
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Inputs
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2)
                ),
              ),

              // Cards
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.1), // Teal tinted shadow (Luxury look)
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ),

            // ================= DARK THEME (Midnight) =================
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,

              // Base Colors
              scaffoldBackgroundColor: AppColors.backgroundDark,
              primaryColor: AppColors.primary,
              cardColor: AppColors.cardDark,
              dividerColor: Colors.white.withOpacity(0.1),

              // Color Scheme
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.backgroundDark,
                background: AppColors.backgroundDark,
              ),

              // Typography
              fontFamily: GoogleFonts.poppins().fontFamily,
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
                bodyColor: AppColors.textPrimaryDark,
                displayColor: Colors.white,
              ),

              // App Bar (Dark Mode)
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.backgroundDark, // Matches background
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700
                ),
              ),

              // Buttons (Using Gold for Contrast in Dark Mode)
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Gold Button
                  foregroundColor: Colors.black, // Black Text
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),

              // Inputs
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.cardDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)
                ),
              ),

              // Cards
              cardTheme: CardThemeData(
                color: AppColors.cardDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.05))),
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ),

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
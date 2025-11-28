import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ScholarNestApp());
}

class ScholarNestApp extends StatelessWidget {
  const ScholarNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

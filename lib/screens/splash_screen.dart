import 'dart:async';
import 'package:flutter/material.dart';
import 'intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.jpeg',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 2),

            // Main Title (matches logo style)
            Text(
              'SCHOLOR NEST',
              style: TextStyle(
                fontFamily: 'Literata',        // closest match to logo style
                fontSize: 26,
                fontWeight: FontWeight.w800,   // thick bold like logo
                letterSpacing: 2.2,            // matches the logo spacing
                color: Color(0xFF0D1C2E),      // very dark navy (same as logo)
              ),
            ),

            const SizedBox(height: 6),

            // Underline bars (same as logo)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 2.2,
                  color: Color(0xFF0D1C2E),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 55,
                  height: 2.2,
                  color: Color(0xFF0D1C2E),
                ),
              ],
            ),
          ],
        )

      ),
    );
  }
}

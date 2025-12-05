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

            /// 🔥 FIXED SPACING — looks exactly like your screenshot
            ClipRect(
              child: Image.asset(
                'assets/logo.jpeg',
                width: 150,
                height: 120,
                fit: BoxFit.fill,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'SCHOLOR NEST',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: Color(0xFF0D1C2E),
              ),
            ),

            const SizedBox(height: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 2.2,
                  color: Color(0xFF0D1C2E),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 55,
                  height: 2.2,
                  color: Color(0xFF0D1C2E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

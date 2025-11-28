import 'package:flutter/material.dart';
import 'home_screen.dart'; // Placeholder for next screen

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              ' Scholar_Nest!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3C53),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              ' Learn . Grow . Achieve',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3C53),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Discover thousands of scholarships tailored to your unique Profile and                   academic goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('NEXT', style: TextStyle(color: Colors.white), ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';
import '../widgets/modern_button.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
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
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // --------------------------------------------------
                  // ✅ BIG ROUND LOGO
                  // --------------------------------------------------
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg', // your logo
                      width: width * 0.50, // bigger logo
                      height: width * 0.50, // make height same as width
                      fit: BoxFit.cover, // cover to fill circle
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --------------------------------------------------
                  // TITLE
                  // --------------------------------------------------
                  Text(
                    'Scholar Nest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------------------------
                  // SUBTITLE
                  // --------------------------------------------------
                  Text(
                    'Learn • Grow • Achieve',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // --------------------------------------------------
                  // DESCRIPTION
                  // --------------------------------------------------
                  Text(
                    'Discover thousands of scholarships tailored to your profile and academic goals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 46),

                  // --------------------------------------------------
                  // NEXT BUTTON
                  // --------------------------------------------------
                  ModernButton(
                    text: "NEXT",
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      AdService().showAdWithCounter();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

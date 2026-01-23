import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/colors.dart';
import 'intro_screen.dart'; // Ensure this points to your IntroScreen file
import '../widgets/modern_button.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // ----------------------------------------------------------------
  // 1. DATA FOR YOUR 3 SLIDES
  // ----------------------------------------------------------------
  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Find Scholarships",
      "subtitle": "Discover thousands of scholarships tailored to your academic profile and career goals.",
      // Using Icons for now. You can switch to 'assets/image.png' later.
      "icon": Icons.school_rounded,
    },
    {
      "title": "Expert Guidance",
      "subtitle": "Connect with top mentors to refine your essays, applications, and interview skills.",
      "icon": Icons.support_agent_rounded,
    },
    {
      "title": "Track Success",
      "subtitle": "Save opportunities, track deadlines, and manage your application journey in one place.",
      "icon": Icons.emoji_events_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToNextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // ----------------------------------------------------------------
  // 2. FINISH LOGIC (Save Flag & Navigate)
  // ----------------------------------------------------------------
  Future<void> _finishOnboarding() async {
    // Save that the user has seen the walkthrough
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenWalkthrough', true);

    if (!mounted) return;

    // Navigate to Intro Screen (Replace, so they can't go back)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --------------------------------------------------
              // TOP BAR (Skip Button)
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      "SKIP",
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------
              // SLIDER AREA
              // --------------------------------------------------
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // -- Circular Image/Icon Container --
                          Container(
                            width: width * 0.7, // Responsive width
                            height: width * 0.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.4), // Glassy white
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            // Replace this Icon with Image.asset(...) if you have images
                            child: Icon(
                              slide['icon'],
                              size: width * 0.3,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 50),

                          // -- Title --
                          Text(
                            slide['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Literata', // Matches your branding
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // -- Subtitle --
                          Text(
                            slide['subtitle'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --------------------------------------------------
              // BOTTOM CONTROLS
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
                child: Column(
                  children: [
                    // -- Dots Indicator --
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentIndex == index ? 24 : 8, // Active dot stretches
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // -- Main Button --
                    ModernButton(
                      text: isLastPage ? "GET STARTED" : "NEXT",
                      onPressed: _goToNextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants/colors.dart';

class HowToApplyScreen extends StatefulWidget {
  const HowToApplyScreen({super.key});

  @override
  State<HowToApplyScreen> createState() => _HowToApplyScreenState();
}

class _HowToApplyScreenState extends State<HowToApplyScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // System is ready for the manager's video URL
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(''),
    )..initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // ---------------- HEADER (MATCHED TO PROFESSOR LIST) ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF6a8dbd),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  // Using Icons.arrow_back as used in your ProfessorListScreen
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  // Left-aligned Header Text (No underline)
                  const Text(
                    "How to Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Literata',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ---------------- VIDEO CONTENT ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isInitialized
                        ? VideoPlayer(_videoController)
                        : const Center(
                      child: Icon(Icons.play_circle_fill, size: 75, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Vedio Title (Underlined to match design)
                  const Text(
                    "Vedio Title",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Literata',
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
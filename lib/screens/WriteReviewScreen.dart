import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../constants/colors.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/modern_button.dart';

class WriteReviewScreen extends StatefulWidget {
  final int consultantId;

  const WriteReviewScreen({super.key, required this.consultantId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a comment")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await ApiService.submitReview(
      consultantId: widget.consultantId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Submission failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top;

    // 2. ADAPTIVE COLORS
    // Text Color: Dark Blue in Light Mode, White in Dark Mode
    final Color sectionTitleColor = isDarkMode ? Colors.white : AppColors.primary;
    // Card Background: White in Light Mode, Dark Grey in Dark Mode
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.9);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // 3. ADAPTIVE BACKGROUND (Gradient vs Solid Dark)
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // ---------------- GLASS HEADER ----------------
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: topPadding + 15,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.90),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),

                      // Title
                      const Text(
                        "Write Your Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Invisible Spacer
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------- FORM BODY ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // CARD CONTAINER FOR FORM
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: cardColor, // Uses Adaptive Color
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black.withOpacity(0.3) : AppColors.primary.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // RATING SECTION
                          Center(
                            child: Text(
                              "How was your experience?",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: sectionTitleColor // Adaptive Color
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _rating = index + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 42,
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 30),

                          // COMMENT LABEL
                          Text(
                            "Your Feedback",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: sectionTitleColor // Adaptive Color
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TEXT FIELD
                          // Note: Ensure ModernTextField uses Theme.of(context) internally or passing colors manually if needed.
                          // Usually standard TextFields adapt automatically to dark mode.
                          Container(
                            decoration: BoxDecoration(
                              // Optional: Ensure input background is distinct in dark mode if needed
                              color: isDarkMode ? Colors.grey[900] : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ModernTextField(
                              controller: _commentController,
                              maxLines: 6,
                              hintText: "Share details about your consultation...",
                            ),
                          ),

                          const SizedBox(height: 30),

                          // SUBMIT BUTTON
                          ModernButton(
                            text: "Submit Review",
                            onPressed: _isSubmitting ? () {} : _submit,
                            isLoading: _isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
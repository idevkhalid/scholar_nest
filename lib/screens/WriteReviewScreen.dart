import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import '../services/api_service.dart';

// --- COLOR CONSTANTS (Merged for consistency) ---
class AppColors {
  static const Color primary = Color(0xFF1B3C53);
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x9977A9FF), // Light Blue-ish top
      Colors.white,      // White bottom
    ],
  );
}

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
    // Get status bar height
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      // 1. EXTEND BODY BEHIND APP BAR (Crucial for gradient to go to top)
      extendBodyBehindAppBar: true,
      body: Container(
        // 2. BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
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
                    top: topPadding + 15, // Space for status bar
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3), // Requested transparency
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25), // Subtle border
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

                      // Invisible Spacer to balance the layout
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
                        color: Colors.white.withOpacity(0.9), // Slight transparency for glass effect
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // RATING SECTION
                          const Center(
                            child: Text(
                              "How was your experience?",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary
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
                          const Text(
                            "Your Feedback",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TEXT FIELD
                          TextField(
                            controller: _commentController,
                            maxLines: 6,
                            style: const TextStyle(color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: "Share details about your consultation...",
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.primary.withOpacity(0.05),
                              contentPadding: const EdgeInsets.all(15),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // SUBMIT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                                  : const Text(
                                  "Submit Review",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                            ),
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
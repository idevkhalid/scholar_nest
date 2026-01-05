import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    // Define your primary color manually if AppColors is not available
    const primaryColor = Color(0xFF1B3C53);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ---------------------------------------------
          // COMPACT HEADER (Single Row, Short Height)
          // ---------------------------------------------
          Container(
            width: double.infinity,
            // Reduced padding: Top 45 (for status bar), Bottom 15 (compact)
            padding: const EdgeInsets.only(top: 45, left: 15, right: 15, bottom: 15),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3), // Requested Color
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20), // Smaller radius for compact look
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Vertically Center
              children: [
                // Back Button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(5.0), // Hit area
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),

                // Title (Expanded ensures it takes up the remaining space)
                const Expanded(
                  child: Text(
                    "Write Your Review",
                    textAlign: TextAlign.center, // Center text horizontally
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Invisible box to balance the Row so text stays perfectly centered
                const SizedBox(width: 34),
              ],
            ),
          ),

          // ---------------------------------------------
          // FORM BODY
          // ---------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Rate your experience",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Star Rating Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setState(() => _rating = index + 1),
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 40,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Your Comment",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Comment Box
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your experience...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50, // Slightly smaller button
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text("Submit Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
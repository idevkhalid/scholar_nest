import 'package:flutter/material.dart';

class ConsultantProfileScreen extends StatelessWidget {
  const ConsultantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using the same gradient style as your other screens
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x9977A9FF), // Light Blue Top
            Colors.white,      // White Bottom
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Circular Profile Image ---
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. Header Name ---
              const Text(
                "Consulted Name",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3C53),
                ),
              ),
              const Divider(thickness: 1.5, color: Colors.black87),
              const SizedBox(height: 20),

              // --- 3. Info Section ---
              _buildInfoRow("Experience:"),
              _buildInfoRow("Phone Number:"),
              _buildInfoRow("Alternative Phone Number:"),
              _buildInfoRow("Company Name/Website Link:"),

              const SizedBox(height: 15),
              const Text(
                "Provider Address:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  color: Color(0xFF1B3C53),
                ),
              ),
              const SizedBox(height: 15),

              _buildInfoRow("State/City:"),
              const Divider(color: Colors.black54),
              const SizedBox(height: 10),

              _buildInfoRow("Qualification:"),
              const Divider(color: Colors.black54),
              const SizedBox(height: 10),

              _buildInfoRow("Language:"),
              const Text(
                "What language can speak a provider:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1B3C53),
                ),
              ),
              const Divider(color: Colors.black54),
              const SizedBox(height: 20),

              // --- 4. Social Media Section ---
              const Text(
                "Social media Links:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1B3C53),
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoRow("Facebook:"),
              _buildInfoRow("you tube:"),
              _buildInfoRow("Instagram:"),
              const Divider(color: Colors.black54),
              const SizedBox(height: 10),

              // --- 5. Rating Stars (Big Outlines) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.star_border, size: 45, color: Colors.black),
                  Icon(Icons.star_border, size: 45, color: Colors.black),
                  Icon(Icons.star_border, size: 45, color: Colors.black),
                  Icon(Icons.star_border, size: 45, color: Colors.black),
                  Icon(Icons.star_border, size: 45, color: Colors.black),
                ],
              ),
              const SizedBox(height: 30),

              // --- 6. Review Cards ---
              _buildReviewCard(
                reviewerName: "Here's reviewer Name:",
                timeAgo: "5 months ago",
                ratingScore: "5/4",
                reviewText:
                "User Reviews and Feedback Interface. User reviews online. Customer feedback review experience Rating concept",
              ),
              const SizedBox(height: 20),
              _buildReviewCard(
                reviewerName: "Here's reviewer Name:",
                timeAgo: "9 months ago",
                ratingScore: "5/5",
                reviewText:
                "A \"review box\" generally refers to a website element displaying customer feedback (testimonials, ratings) or a software.",
              ),

              const SizedBox(height: 20),
              const Text(
                "See more Reviews",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Color(0xFF1B3C53),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Rows like "Experience:" ---
  Widget _buildInfoRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1B3C53),
            ),
          ),
          // You can add value text here later if needed
        ],
      ),
    );
  }

  // --- Helper Widget for the Review Card ---
  Widget _buildReviewCard({
    required String reviewerName,
    required String timeAgo,
    required String ratingScore,
    required String reviewText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Time + Rating Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1B3C53),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: " $timeAgo",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                ratingScore,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Yellow Stars
          Row(
            children: const [
              Icon(Icons.star, color: Colors.yellow, size: 20),
              Icon(Icons.star, color: Colors.yellow, size: 20),
              Icon(Icons.star, color: Colors.yellow, size: 20),
              Icon(Icons.star, color: Colors.yellow, size: 20),
              Icon(Icons.star_border, color: Colors.yellow, size: 20),
            ],
          ),
          const SizedBox(height: 10),

          // Review Body
          Text(
            reviewText,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 10),

          // Thumbs Up/Down
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.thumb_up_alt_outlined, size: 20),
              SizedBox(width: 15),
              Icon(Icons.thumb_down_alt_outlined, size: 20),
            ],
          )
        ],
      ),
    );
  }
}
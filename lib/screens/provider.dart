import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConsultantProfileScreen extends StatefulWidget {
  final int consultantId;

  const ConsultantProfileScreen({
    super.key,
    required this.consultantId,
  });

  @override
  State<ConsultantProfileScreen> createState() =>
      _ConsultantProfileScreenState();
}

class _ConsultantProfileScreenState extends State<ConsultantProfileScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getConsultantDetails(widget.consultantId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x9977A9FF),
            Colors.white,
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                snapshot.data!["status"] == "error") {
              return const Center(child: Text("Failed to load provider"));
            }

            final data = snapshot.data!["data"];
            final user = data["user"];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Circular Profile Image ---
                  Center(
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(user["avatar"]),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. Header Name ---
                  Text(
                    user["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3C53),
                    ),
                  ),
                  const Divider(thickness: 1.5, color: Colors.black87),
                  const SizedBox(height: 20),

                  // --- 3. Info Section ---
                  _buildInfoRow(
                      "Experience: ${data["experience_years"]} years"),
                  _buildInfoRow("Phone Number: ${user["phone"]}"),
                  _buildInfoRow("Company/Website: ${data["website"] ?? "-"}"),

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

                  _buildInfoRow("State/City: ${user["location"]}"),
                  const Divider(color: Colors.black54),
                  const SizedBox(height: 10),

                  _buildInfoRow("Qualification: ${data["education"]}"),
                  const Divider(color: Colors.black54),
                  const SizedBox(height: 10),

                  _buildInfoRow(
                    "Language: ${(data["languages"] as List).join(", ")}",
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
                  _buildInfoRow("LinkedIn: ${data["linkedin"] ?? "-"}"),
                  _buildInfoRow("Twitter: ${data["twitter"] ?? "-"}"),
                  const Divider(color: Colors.black54),
                  const SizedBox(height: 10),

                  // --- 5. Rating Stars ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < data["avg_rating"].round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 45,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 6. Review Cards ---
                  ...List.generate(
                    data["recent_reviews"].length,
                        (index) {
                      final review = data["recent_reviews"][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildReviewCard(
                          reviewerName: "User",
                          timeAgo: review["created_at"],
                          ratingScore: review["rating"].toString(),
                          reviewText: review["comment"],
                        ),
                      );
                    },
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
            );
          },
        ),
      ),
    );
  }

  // --- SAME helper (unchanged) ---
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
        ],
      ),
    );
  }

  // --- SAME review card (unchanged) ---
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3C53),
                ),
              ),
              Text(ratingScore),
            ],
          ),
          const SizedBox(height: 8),
          Text(reviewText),
          const SizedBox(height: 6),
          Text(
            timeAgo,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

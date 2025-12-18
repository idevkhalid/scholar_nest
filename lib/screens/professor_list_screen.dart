import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProfessorListScreen extends StatelessWidget {
  ProfessorListScreen({super.key});

  final List<Map<String, String>> professors = [
    {
      "name": "Dr. Li Wei",
      "details": "PhD Computer Science • Machine Learning",
      "email": "li.wei@university.cn",
    },
    {
      "name": "Prof. James Wilson",
      "details": "PhD Information Technology • Cyber Security",
      "email": "j.wilson@university.edu.au",
    },
    {
      "name": "Dr. Oliver Thompson",
      "details": "PhD Software Engineering • Cloud Computing",
      "email": "oliver.thompson@university.ac.uk",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ---------------- GLASS HEADER (MATCHED) ----------------
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
                    color: AppColors.primary.withAlpha(120),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Professor List",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- LIST ----------------
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: professors.length,
                  itemBuilder: (context, index) {
                    final prof = professors[index];

                    return _knowledgeStyleCard(
                      title: prof["name"]!,
                      description: prof["details"]!,
                      email: prof["email"]!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CARD (UNCHANGED DESIGN) ----------------
  Widget _knowledgeStyleCard({
    required String title,
    required String description,
    required String email,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
            ),
            child: Icon(
              Icons.school_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}

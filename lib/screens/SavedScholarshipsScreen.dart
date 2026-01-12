import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'scholarship_details_screen.dart';
import 'home_screen.dart'; // Make sure this is imported to access ModernScholarshipCard

class SavedScholarshipsScreen extends StatefulWidget {
  const SavedScholarshipsScreen({super.key});

  @override
  State<SavedScholarshipsScreen> createState() => _SavedScholarshipsScreenState();
}

class _SavedScholarshipsScreenState extends State<SavedScholarshipsScreen> {
  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final savedList = savedProvider.savedList;

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
                      color: AppColors.primary.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Saved Scholarships",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.bookmark, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ---------------- BODY ----------------
              Expanded(
                child: savedList.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 60, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      const Text(
                        "No saved scholarships yet.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: savedList.length,
                  itemBuilder: (context, index) {
                    final item = savedList[index];

                    // Using the EXACT same widget from Home Screen
                    return ModernScholarshipCard(
                      title: item['title']?.toString() ?? 'No Title',
                      institution: item['university']?.toString() ?? 'No Institution',
                      badge: "${item['amount'] ?? ''} ${item['currency'] ?? ''}".trim(),
                      deadline: item['deadline']?.toString() ?? 'No Deadline',
                      country: item['country']?.toString() ?? 'N/A',
                      isSaved: true, // It's in the saved screen, so it's always true
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScholarshipDetailsPage(
                              scholarshipId: int.parse(item['id'].toString()),
                            ),
                          ),
                        );
                      },
                      onSave: () {
                        // Tapping bookmark in saved screen removes it
                        savedProvider.toggleSave(item);
                      },
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
}
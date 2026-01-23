import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import '../providers/saved_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../widgets/modern_scholarship_card.dart';
import '../widgets/premium_background.dart';

// Screens
import 'scholarship_details_screen.dart';

class SavedScholarshipsScreen extends StatefulWidget {
  const SavedScholarshipsScreen({super.key});

  @override
  State<SavedScholarshipsScreen> createState() =>
      _SavedScholarshipsScreenState();
}

class _SavedScholarshipsScreenState
    extends State<SavedScholarshipsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth =
      Provider.of<AuthProvider>(context, listen: false);
      final savedProvider =
      Provider.of<SavedProvider>(context, listen: false);

      if (auth.isLoggedIn && auth.userToken.isNotEmpty) {
        // 1. Load local cache first
        if (savedProvider.savedList.isEmpty) {
          savedProvider.loadLocalData().then((_) {
            // 2. Background sync from API
            savedProvider.fetchSavedScholarships(
                auth.userToken);
          });
        } else {
          // Already loaded → background sync
          savedProvider.fetchSavedScholarships(
              auth.userToken);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final savedList = savedProvider.savedList;

    final double topPadding =
        MediaQuery.of(context).padding.top;

    return Scaffold(
      body: PremiumBackground(
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
                  filter:
                  ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: topPadding + 15,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color:
                      AppColors.primary.withOpacity(0.85),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border.all(
                          color:
                          Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Saved Scholarships",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ---------------- BODY ----------------
              Expanded(
                child: savedProvider.isLoading &&
                    savedList.isEmpty
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : savedList.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 60,
                        color: AppColors.primary
                            .withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No saved scholarships yet.",
                        style: TextStyle(
                          color: AppColors
                              .textSecondary
                              .withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  itemCount: savedList.length,
                  itemBuilder: (context, index) {
                    final item = savedList[index];

                    final String title =
                        item['title']?.toString() ??
                            'No Title';
                    final String university =
                        item['university']
                            ?.toString() ??
                            'No Institution';
                    final String amount =
                        item['amount']
                            ?.toString() ??
                            '';
                    final String currency =
                        item['currency']
                            ?.toString() ??
                            '';
                    final String country =
                        item['country']
                            ?.toString() ??
                            'N/A';

                    // --- DATE FIX ---
                    String deadline =
                        item['deadline']
                            ?.toString() ??
                            'Open';
                    if (deadline.contains('T')) {
                      deadline =
                      deadline.split('T')[0];
                    } else if (deadline
                        .contains(' ')) {
                      deadline =
                      deadline.split(' ')[0];
                    }

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                          bottom: 16),
                      child: ModernScholarshipCard(
                        title: title,
                        institution: university,
                        badge:
                        "$amount $currency".trim(),
                        deadline: deadline,
                        country: country,
                        isSaved: true,

                        onTap: () {
                          if (item['id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScholarshipDetailsPage(
                                      scholarshipId:
                                      int.parse(item[
                                      'id']
                                          .toString()),
                                    ),
                              ),
                            );
                          }
                        },

                        onSave: () {
                          if (authProvider
                              .userToken
                              .isNotEmpty) {
                            savedProvider.toggleSave(
                              item,
                              authProvider
                                  .userToken,
                            );
                          }
                        },
                      ),
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

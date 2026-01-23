import 'dart:ui';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../services/ad_service.dart';
import 'how_to apply _screen.dart';
import 'professor_list_screen.dart';
import 'ConsultantListScreen.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Column(
        children: [

          // ===============================================
          // 1. HEADER
          // ===============================================
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Header Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 15),
                    // Header Text
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Knowledge Base",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Everything you need to know",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===============================================
          // 2. BODY
          // ===============================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [

                // 1. HOW TO APPLY
                _professionalCard(
                  context,
                  title: "How to Apply",
                  subtitle: "Step-by-step guidance",
                  icon: Icons.history_edu_rounded,
                  isDark: isDark,
                  onTap: () {
                    AdService().showAdWithCounter();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToApplyScreen()));
                  },
                ),

                const SizedBox(height: 16),

                // 2. PROFESSOR LIST
                _professionalCard(
                  context,
                  title: "Professor List",
                  subtitle: "Find mentors & supervisors",
                  icon: Icons.school_rounded,
                  isDark: isDark,
                  onTap: () {
                    AdService().showAdWithCounter();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessorListScreen()));
                  },
                ),

                const SizedBox(height: 16),

                // 3. CONSULTANTS
                _professionalCard(
                  context,
                  title: "Consultants",
                  subtitle: "Get expert assistance",
                  icon: Icons.handshake_rounded,
                  isDark: isDark,
                  onTap: () {
                    AdService().showAdWithCounter();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllConsultantScreen()));
                  },
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PROFESSIONAL CARD WIDGET ----------------
  Widget _professionalCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
        required bool isDark,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Row(
              children: [
                // 1. ICON BOX
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Deep Teal Box
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white, // ✅ CHANGED TO WHITE
                    size: 26,
                  ),
                ),

                const SizedBox(width: 20),

                // 2. TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. ARROW
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.withOpacity(0.3),
                  size: 16,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
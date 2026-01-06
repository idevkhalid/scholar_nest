import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholar_nest/screens/user_profile_screen.dart';

import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import 'SavedScholarshipsScreen.dart';
import 'about_us_screen.dart';
import 'contact_support_screen.dart';
import 'delete_account_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Get user initials from name
  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final initials = _getInitials(authProvider.userName);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ================= HEADER =================
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
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.userName.isNotEmpty
                                      ? authProvider.userName
                                      : "Guest User",
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.email.isNotEmpty
                                      ? authProvider.email
                                      : "Login to access full features",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= OPTIONS CARD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _profileTile(Icons.person, "Profile", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const UserProfileScreen(),
                            ),
                          );
                        }),

                        _divider(),

                        _profileTile(Icons.bookmark, "Saved Scholarships", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const SavedScholarshipsScreen(),
                            ),
                          );
                        }),

                        _divider(),

                        _profileTile(
                            Icons.support_agent, "Contact / Support", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ContactSupportScreen(),
                            ),
                          );
                        }),

                        _divider(),

                        _profileTile(
                            Icons.delete_outline, "Delete Account", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const DeleteAccountScreen(),
                            ),
                          );
                        }),

                        _divider(),

                        _profileTile(Icons.info_outline, "About Us", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutUsScreen(),
                            ),
                          );
                        }),

                        _divider(),

                        _profileTile(
                            Icons.lock_outline, "Privacy & Security", () {}),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= LOGOUT BUTTONS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Logout
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authProvider.isLoggedIn
                              ? () async {
                            await authProvider.logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const LoginScreen(),
                              ),
                            );
                          }
                              : null,
                          icon: const Icon(Icons.logout,
                              color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Logout all devices
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authProvider.isLoggedIn
                              ? () async {
                            await authProvider.logoutAllDevices();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const LoginScreen(),
                              ),
                            );
                          }
                              : null,
                          icon: const Icon(Icons.logout_outlined,
                              color: Colors.white),
                          label: const Text(
                            "Logout All Devices",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE TILE =================
  Widget _profileTile(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.8,
      indent: 20,
      endIndent: 20,
    );
  }
}
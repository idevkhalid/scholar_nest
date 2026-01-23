import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../widgets/modern_button.dart';
import '../widgets/premium_background.dart';

// Screens
import 'SavedScholarshipsScreen.dart';
import 'about_us_screen.dart';
import 'contact_support_screen.dart';
import 'delete_account_screen.dart';
import 'login_screen.dart';
import 'privacy_screen.dart';
import 'user_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // --- THEME SELECTOR MODAL ---
  void _showAppearanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                // Picks up the Midnight Blue in Dark Mode
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                border: isDark
                    ? Border.all(color: Colors.white.withOpacity(0.1))
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Theme",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildThemeOption(
                        context,
                        "System Default",
                        Icons.brightness_auto,
                        themeProvider.themeMode == ThemeMode.system,
                        ThemeMode.system
                    ),
                    _buildThemeOption(
                        context,
                        "Light Mode",
                        Icons.wb_sunny_outlined,
                        themeProvider.themeMode == ThemeMode.light,
                        ThemeMode.light
                    ),
                    _buildThemeOption(
                        context,
                        "Dark Mode",
                        Icons.nightlight_round,
                        themeProvider.themeMode == ThemeMode.dark,
                        ThemeMode.dark
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, IconData icon, bool isSelected, ThemeMode mode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In Dark Mode, use Gold/White for selected items so they are visible
    final activeColor = isDark ? AppColors.secondary : AppColors.primary;
    final inactiveColor = isDark ? Colors.white54 : Colors.grey;

    return ListTile(
      leading: Icon(icon, color: isSelected ? activeColor : inactiveColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Highlight selected text with Gold in dark mode, Blue in light mode
          color: isSelected
              ? activeColor
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: activeColor)
          : null,
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false).setTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final initials = _getInitials(authProvider.userName);
    final double topPadding = MediaQuery.of(context).padding.top;

    // Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background handles gradient switching automatically
      body: PremiumBackground(
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
                        // Keep header Brand Color (Deep Blue) in both modes for identity
                        color: AppColors.primary.withOpacity(0.90),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5)
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Text(
                              initials,
                              style: const TextStyle(
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
                                  authProvider.userName.isNotEmpty ? authProvider.userName : "Guest User",
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.email.isNotEmpty ? authProvider.email : "Login to access full features",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13
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
                      // Uses 'cardColor' defined in main.dart (White vs Slate Blue)
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? Border.all(color: Colors.white.withOpacity(0.05)) // Subtle border in dark mode
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _profileTile(context, Icons.person, "Edit Profile", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
                        }),

                        _divider(context),

                        // --- APPEARANCE OPTION ---
                        _profileTile(context, Icons.palette_outlined, "Appearance", () {
                          _showAppearanceModal(context);
                        }),

                        _divider(context),

                        _profileTile(context, Icons.bookmark, "Saved Scholarships", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScholarshipsScreen()));
                        }),

                        _divider(context),

                        _profileTile(context, Icons.support_agent, "Contact / Support", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen()));
                        }),

                        _divider(context),

                        _profileTile(context, Icons.delete_outline, "Delete Account", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
                        }),

                        _divider(context),

                        _profileTile(context, Icons.info_outline, "About Us", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                        }),

                        _divider(context),

                        _profileTile(context, Icons.lock_outline, "Privacy & Security", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= LOGOUT BUTTON =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ModernButton(
                    text: "Logout",
                    icon: Icons.logout,
                    onPressed: authProvider.isLoggedIn
                        ? () async {
                      await authProvider.logout();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }
                        : null,
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
  Widget _profileTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Light Mode: Light Blue BG. Dark Mode: White transparent BG (so it shines)
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        // Light Mode: Dark Blue Icon. Dark Mode: White Icon (High Contrast)
        child: Icon(
          icon,
          color: isDark ? Colors.white : AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          // Adapts to Soft White in dark mode
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 20,
      endIndent: 20,
      // Divider becomes very subtle in dark mode
      color: Theme.of(context).dividerColor,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  Map<String, dynamic>? settings;
  bool isLoading = true;

  // --- ACCENT COLOR (Keep Gold for both modes) ---
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final response = await ApiService.getPublicSettings();
    if (mounted) {
      setState(() {
        if (response['success'] == true) {
          settings = response['data'];
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. ADAPTIVE COLORS
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryText = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final Color secondaryText = isDarkMode ? Colors.grey[400]! : Colors.grey.shade600;
    final Color iconBgColor = isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFF0F4F8);

    // Get the actual version from API (default to '...' if loading)
    final String actualVersion = settings?['app_version'] ?? "Loading...";

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER WITH OPACITY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
              decoration: BoxDecoration(
                // In dark mode, we keep the primary color but maybe slightly darker or transparent
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  // Logo Circle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.school_rounded, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 15),

                  // App Name
                  Text(
                    settings?['app_name'] ?? "ScholarNest",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // VERSION BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Version $actualVersion",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary // Keep dark text on gold bg
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- INFO CARD ---
            Transform.translate(
              offset: const Offset(0, -30), // Pull up effect
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardColor, // Adaptive Card Color
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.3) : AppColors.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact Support",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : AppColors.primary.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: "Email Support",
                        value: settings?['support_email'],
                        onTap: () => _launchUri('mailto:${settings?['support_email']}'),
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        iconBg: iconBgColor,
                      ),
                      Divider(height: 35, thickness: 0.5, color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),

                      _buildInfoRow(
                        icon: Icons.headset_mic_outlined,
                        label: "Helpline",
                        value: settings?['support_number_1'],
                        onTap: () => _launchUri('tel:${settings?['support_number_1']}'),
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        iconBg: iconBgColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- COMPANY / DEVELOPER INFO ---
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  "Developed by",
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                // COMPANY NAME
                Text(
                  "Codes Solution (PVT) LTD",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "© 2026 All Rights Reserved",
                  style: TextStyle(color: secondaryText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
    required Color primaryText,
    required Color secondaryText,
    required Color iconBg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: secondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "N/A",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: secondaryText),
        ],
      ),
    );
  }

  void _launchUri(String? uriString) async {
    if (uriString == null) return;
    final Uri url = Uri.parse(uriString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
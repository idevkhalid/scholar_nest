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

  // --- COLORS ---
  static const Color darkPrimary = Color(0xFF1B3C53);  // Dark Navy
  static const Color background = Color(0xFFF5F7FA);   // Light Grey
  static const Color accentGold = Color(0xFFD4AF37);   // Gold Accent

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
    // 1. Get the actual version from API (default to '...' if loading)
    final String actualVersion = settings?['app_version'] ?? "Loading...";

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true, // Allows header to go behind status bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent so custom header shows
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
          ? const Center(child: CircularProgressIndicator(color: darkPrimary))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER WITH OPACITY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 50), // Top padding for status bar
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
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

                  // 3. ACTUAL VERSION BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Version $actualVersion", // Uses API data
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkPrimary.withOpacity(0.08),
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
                            color: darkPrimary.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: "Email Support",
                        value: settings?['support_email'],
                        onTap: () => _launchUri('mailto:${settings?['support_email']}'),
                      ),
                      const Divider(height: 35, thickness: 0.5),

                      _buildInfoRow(
                        icon: Icons.headset_mic_outlined,
                        label: "Helpline",
                        value: settings?['support_number_1'],
                        onTap: () => _launchUri('tel:${settings?['support_number_1']}'),
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
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                // 👇 UPDATED COMPANY NAME
                const Text(
                  "Codes Solution (PVT) LTD",
                  style: TextStyle(
                    color: darkPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "© 2026 All Rights Reserved",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: darkPrimary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "N/A",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
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
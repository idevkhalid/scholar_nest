import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import '../widgets/modern_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? policyLink;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLink();
  }

  void _fetchLink() async {
    try {
      final response = await ApiService.getPublicSettings();

      if (mounted) {
        setState(() {
          isLoading = false;
          if (response != null && response['success'] == true && response['data'] != null) {
            policyLink = response['data']['privacy_policy_link'];
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 👇 HELPER: Fix Google Drive Links to be Direct Download Links
  String _getDirectUrl(String originalUrl) {
    if (originalUrl.contains("drive.google.com") && originalUrl.contains("/file/d/")) {
      final parts = originalUrl.split('/file/d/');
      if (parts.length > 1) {
        final idPart = parts[1].split('/')[0];
        return "https://drive.google.com/uc?export=download&id=$idPart";
      }
    }
    return originalUrl;
  }

  void _openPDFViewer() {
    if (policyLink != null && policyLink!.isNotEmpty) {
      final directLink = _getDirectUrl(policyLink!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InternalPDFViewer(
            pdfUrl: directLink,
            title: "Policy",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Policy document not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. ADAPTIVE COLORS
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFEAF1F8);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : AppColors.primary;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          // Ensure icon is visible on top of the header background
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy & Security",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 50),
              decoration: BoxDecoration(
                // Darker opacity in dark mode, lighter in light mode, but keeping it Blue-ish
                color: AppColors.primary.withOpacity(0.85),
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
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.security_rounded, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Data Protection",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white, // Changed to White for contrast against Blue Header
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Verified & Secure",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // --- INFO CARD ---
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardColor, // Adaptive Card
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.3) : AppColors.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "We respect your privacy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Your personal data is encrypted and stored securely. Tap below to read the full official documentation directly in the app.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      ModernButton(
                        text: "Read Full Policy",
                        onPressed: _openPDFViewer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// INTERNAL PDF VIEWER PAGE
// =========================================================
class InternalPDFViewer extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const InternalPDFViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Theme check for PDF Viewer background
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFEAF1F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white, // Changed to White for visibility
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Icon color white to match text
        iconTheme: const IconThemeData(color: Colors.white),
        // Header Decoration
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha:0.9), // Dark Blue Header
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .1),
            ),
          ),
        ),
      ),
      body: const PDF().fromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
        errorWidget: (error) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text("Could not load document."),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Error: $error", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        )),
      ),
    );
  }
}
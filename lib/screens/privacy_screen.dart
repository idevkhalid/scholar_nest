import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? policyLink;
  bool isLoading = true;

  // Using the Dark Navy as "primary"
  static const Color primaryColor = Color(0xFF1B3C53);

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

  // 👇 SPECIAL FUNCTION TO FIX GOOGLE DRIVE LINKS
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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy & Security",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 50),
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
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.security_rounded, size: 50, color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Data Protection",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Verified & Secure",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // --- WHITE CARD ---
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "We respect your privacy",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Your personal data is encrypted and stored securely. Tap below to read the full official documentation directly in the app.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _openPDFViewer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Read Full Policy",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
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

  // Use local constant to ensure it works even if AppColors import is missing
  static const Color primaryColor = Color(0xFF1B3C53);

  const InternalPDFViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: primaryColor, // Dark text to contrast with light opacity header
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Must be transparent to show flexibleSpace
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        // 👇 CUSTOM HEADER DECORATION
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: .6), // Matches your request
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .7),
            ),
          ),
        ),
      ),
      // 👇 Padding removed so PDF connects directly to header
      body: const PDF().fromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
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
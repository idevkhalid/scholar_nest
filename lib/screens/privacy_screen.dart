import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Using the Dark Navy as "primary" for this screen
  static const Color primaryColor = Color(0xFF1B3C53);

  @override
  void initState() {
    super.initState();
    _fetchLink();
  }

  void _fetchLink() async {
    final response = await ApiService.getPublicSettings();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (response['success'] == true) {
          policyLink = response['data']['privacy_policy_link'];
        }
      });
    }
  }

  void _launchPolicy() async {
    if (policyLink != null) {
      final Uri url = Uri.parse(policyLink!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch link")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Policy link not available")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A slightly darker background helps the opacity pop
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
            // --- YOUR CUSTOM HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 50),
              // 👇 This is the exact decoration you asked for
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.6),
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
                  // Icon with matching style
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
                      Text(
                        "We respect your privacy",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Your personal data is encrypted and stored securely. Review our full privacy terms to understand how we protect your information.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _launchPolicy,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                              "View Privacy Policy",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
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
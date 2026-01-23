import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart'; // Import your ApiService
import '../widgets/modern_text_field.dart';
import '../widgets/modern_button.dart';
import '../widgets/premium_background.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // --- API CALL ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Close keyboard
    FocusScope.of(context).unfocus();

    final response = await ApiService.submitContactForm(
      fullName: nameController.text.trim(),
      contactNumber: contactController.text.trim(),
      email: emailController.text.trim(),
      message: messageController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['status'] == 'success') {
      // 1. Show Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 2. Clear Form
      nameController.clear();
      contactController.clear();
      emailController.clear();
      messageController.clear();
    } else {
      // 3. Show Error Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: PremiumBackground( // Use Unified Background
        child: SafeArea( // PremiumBackground doesn't have Safe Area by default, but we control it here
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ================= GLASS HEADER =================
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
                        bottom: 22,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85), // Darker Navy for consistency
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Contact & Support",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins', // Enforce font
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= FORM CARD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground, // Ensure this color exists in your constants
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Need Help?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Fill the form below and our team will contact you.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),

                          // Name
                          ModernTextField(
                            controller: nameController,
                            hintText: "Full Name",
                            labelText: "Full Name",
                            prefixIcon: Icons.person,
                            validator: (value) =>
                                value!.isEmpty ? "Enter your name" : null,
                          ),
                          const SizedBox(height: 15),

                          // Contact
                          ModernTextField(
                            controller: contactController,
                            hintText: "Contact Number",
                            labelText: "Contact Number",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                value!.isEmpty ? "Enter contact number" : null,
                          ),
                          const SizedBox(height: 15),

                          // Email
                          ModernTextField(
                            controller: emailController,
                            hintText: "Email Address",
                            labelText: "Email Address",
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Enter email address";
                              if (!value.contains('@')) return "Enter a valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Message
                          ModernTextField(
                            controller: messageController,
                            hintText: "Message",
                            labelText: "Message",
                            prefixIcon: Icons.message,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Enter your message";
                              if (value.length < 10) return "Message must be at least 10 chars";
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // Submit Button with Loading State
                          ModernButton(
                            text: "Submit",
                            onPressed: _isLoading ? null : _submitForm,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
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

  // ================= REUSABLE TEXT FIELD =================

}


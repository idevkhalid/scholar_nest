import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Contact & Support",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                          buildTextField(
                            controller: nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (value) =>
                            value!.isEmpty ? "Enter your name" : null,
                          ),

                          // Contact
                          buildTextField(
                            controller: contactController,
                            label: "Contact Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                            value!.isEmpty
                                ? "Enter contact number"
                                : null,
                          ),

                          // Email
                          buildTextField(
                            controller: emailController,
                            label: "Email Address",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                            value!.isEmpty
                                ? "Enter email address"
                                : null,
                          ),

                          // Message
                          buildTextField(
                            controller: messageController,
                            label: "Message",
                            icon: Icons.message,
                            maxLines: 4,
                            validator: (value) =>
                            value!.isEmpty
                                ? "Enter your message"
                                : null,
                          ),

                          const SizedBox(height: 30),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Message sent successfully"),
                                    ),
                                  );

                                  nameController.clear();
                                  contactController.clear();
                                  emailController.clear();
                                  messageController.clear();
                                }
                              },
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

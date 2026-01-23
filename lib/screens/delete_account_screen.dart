import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 're_enter_password_screen.dart';
import '../widgets/modern_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen>
    with SingleTickerProviderStateMixin {
  bool isDeleteSelected = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. COLOR VARIABLES
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white; // Or match your scaffold background
    final titleColor = isDarkMode ? Colors.white : AppColors.primary;
    final bodyTextColor = isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final cancelButtonColor = isDarkMode ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        // Only show gradient in Light Mode, otherwise transparent (to show scaffold bg)
        decoration: BoxDecoration(
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
        ),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --------------------------------------------------
                  // BIG ROUND LOGO
                  // --------------------------------------------------
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      width: width * 0.50,
                      height: width * 0.50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --------------------------------------------------
                  // TITLE
                  // --------------------------------------------------
                  Text(
                    'Delete Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor, // Adaptive Color
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --------------------------------------------------
                  // DESCRIPTION
                  // --------------------------------------------------
                  Text(
                    'Deleting your account will permanently remove your scholarships, documents, and verification data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: bodyTextColor, // Adaptive Color
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --------------------------------------------------
                  // RADIO OPTION
                  // --------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Theme(
                        // Force Radio accent color logic if needed
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: isDarkMode ? Colors.grey : null,
                        ),
                        child: Radio<bool>(
                          value: true,
                          groupValue: isDeleteSelected,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              isDeleteSelected = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "I understand that deleting my account is permanent.",
                          style: TextStyle(
                            fontSize: 14,
                            color: bodyTextColor, // Adaptive Color
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --------------------------------------------------
                  // CONTINUE BUTTON
                  // --------------------------------------------------
                  ModernButton(
                    text: "CONTINUE",
                    icon: Icons.arrow_forward,
                    onPressed: isDeleteSelected
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReEnterPasswordScreen(),
                        ),
                      );
                    }
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // --------------------------------------------------
                  // CANCEL BUTTON
                  // --------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // Border changes color in dark mode so it's visible
                        side: BorderSide(color: cancelButtonColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cancelButtonColor, // Text changes color in dark mode
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import '../widgets/modern_text_field.dart';

class ReEnterPasswordScreen extends StatefulWidget {
  const ReEnterPasswordScreen({super.key});

  @override
  State<ReEnterPasswordScreen> createState() => _ReEnterPasswordScreenState();
}

class _ReEnterPasswordScreenState extends State<ReEnterPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Call the Real API
      final result = await ApiService.deleteAccount(password);

      if (!mounted) return;

      if (result['status'] == 'success') {
        // 2. SUCCESS: Clear data and Logout
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clears all tokens and user data

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );

        // 3. Navigate to Login (Remove all back stack)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        // 4. ERROR (e.g., Wrong Password)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Deletion failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. ADAPTIVE COLORS
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : null; // Null uses gradient
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    final linkColor = isDarkMode ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          // Show gradient only in Light Mode
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // ===== Logo =====
                          Center(
                            child: Container(
                              width: width * 0.50,
                              height: width * 0.50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ===== Password Form Card =====
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: cardColor, // Adaptive Color
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Re-enter Password",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor, // Adaptive
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "To permanently delete your account, please confirm your password.",
                                    style: TextStyle(
                                      color: secondaryTextColor, // Adaptive
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // Pass necessary theme info to ModernTextField if it needs it,
                                  // or wrap it in a Theme widget if it relies on context.
                                  ModernTextField(
                                    controller: _passwordController,
                                    hintText: "Password",
                                    labelText: "Password",
                                    isPassword: true,
                                    prefixIcon: Icons.lock_outline,
                                  ),

                                  const SizedBox(height: 30),

                                  // ===== Confirm (Delete) Button =====
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _handleDeleteAccount,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        backgroundColor: Colors.redAccent, // Always Red for danger
                                        elevation: 5,
                                        shadowColor: Colors.redAccent.withOpacity(0.4),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                          : const Text(
                                        "Confirm Delete",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // ===== Forgot Password =====
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "FORGOT PASSWORD?",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: linkColor, // Adaptive (White/Blue)
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
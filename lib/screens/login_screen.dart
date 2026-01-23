import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // 1. RESTORE ACCOUNT DIALOG
  // ----------------------------------------------------------------
  void _showRestoreDialog(BuildContext context) {
    final restoreEmailCtrl = TextEditingController();
    final restorePassCtrl = TextEditingController();
    bool isRestoring = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Theme check for Dialog
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: Text("Restore Account", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Account deleted? Enter your credentials to restore it.",
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: restoreEmailCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: isDark ? Colors.grey : null),
                        prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.grey : null),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: restorePassCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: isDark ? Colors.grey : null),
                        prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey : null),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                    ),
                    if (isRestoring)
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: CircularProgressIndicator(),
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: isRestoring ? null : () async {
                    setState(() => isRestoring = true);

                    final response = await ApiService.restoreAccount(
                      email: restoreEmailCtrl.text.trim(),
                      password: restorePassCtrl.text.trim(),
                    );

                    setState(() => isRestoring = false);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message']),
                          backgroundColor: response['status'] == 'success'
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Restore", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // 2. LOGIN SUBMIT
  // ----------------------------------------------------------------
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Check your credentials.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 1. THEME DETECTION
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. COLOR VARIABLES
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : null; // Gradient vs Black
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400] : AppColors.textSecondary;
    final inputFillColor = isDarkMode ? Colors.white10 : Colors.grey[100];
    final inputTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Gradient only in Light Mode
          gradient: isDarkMode ? null : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        /// ROUND LOGO
                        ClipOval(
                          child: Image.asset(
                            'assets/logo.jpeg',
                            width: width * 0.40,
                            height: width * 0.40,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: titleColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue your journey',
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                        const SizedBox(height: 30),

                        // --- Form Card ---
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor, // Adaptive
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: emailCtrl,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  isPassword: false,
                                  fillColor: inputFillColor!,
                                  textColor: inputTextColor,
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 12),

                                _buildTextField(
                                  controller: passCtrl,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  fillColor: inputFillColor,
                                  textColor: inputTextColor,
                                  isDarkMode: isDarkMode,
                                ),

                                const SizedBox(height: 20),

                                /// SIGN IN BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: _isLoading
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                /// Forgot Password & Restore Account Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showRestoreDialog(context),
                                      child: Text(
                                        "Restore Account?",
                                        style: TextStyle(
                                            color: Colors.red[300],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordScreen()),
                                        );
                                      },
                                      child: Text(
                                        "Forgot password?",
                                        style: TextStyle(color: isDarkMode ? Colors.blue[200] : AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign Up Text
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: subtitleColor),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const RegisterScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper Widget for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required Color fillColor,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        filled: true,
        fillColor: fillColor,
        prefixIcon: icon != null ? Icon(icon, color: isDarkMode ? Colors.grey[400] : AppColors.primary) : null,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter $label';
        if ((label == 'Password') && v.length < 4) return 'Too short';
        if (label == 'Email' && !v.contains('@')) return 'Enter valid email';
        return null;
      },
    );
  }
}
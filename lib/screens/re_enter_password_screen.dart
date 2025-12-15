import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'delete_account_screen.dart';

class ReEnterPasswordScreen extends StatefulWidget {
  const ReEnterPasswordScreen({super.key});

  @override
  State<ReEnterPasswordScreen> createState() => _ReEnterPasswordScreenState();
}

class _ReEnterPasswordScreenState extends State<ReEnterPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;

  Future<void> _confirmPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ===== DUMMY PASSWORD VERIFICATION =====
      // Replace this block with your actual API call later
      await Future.delayed(const Duration(seconds: 1)); // simulate API
      if (password == "123456") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // ===== Updated background color to gradient =====
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
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

                          // ===== Updated Logo Style =====
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

                          // ===== Password Form =====
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Re-enter Password",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "For your security, please re-enter your password to continue.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  TextField(
                                    controller: _passwordController,
                                    obscureText: isObscure,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: AppColors.primary),
                                      ),
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: AppColors.primary),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () {
                                          setState(() => isObscure = !isObscure);
                                        },
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 18),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // ===== Confirm Button =====
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _confirmPassword,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text(
                                        "Confirm",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
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
                                            builder: (_) =>
                                            const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "FORGOT PASSWORD?",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
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

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/modern_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp; // OTP passed from previous screen

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool isLoading = false;

  // Reset password
  Future<void> resetPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.resetPassword(
      email: widget.email,
      otp: widget.otp,
      password: password,
      passwordConfirmation: confirm,
    );

    setState(() => isLoading = false);

    if (response["status"] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully")),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Failed to reset password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Enter your new password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
             Text(
              "Please create a strong password that you can remember.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 30),

            // New Password
            ModernTextField(
              controller: passwordController,
              labelText: "New Password",
              hintText: "••••••••",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            // Confirm Password
            ModernTextField(
              controller: confirmController,
              labelText: "Confirm Password",
              hintText: "••••••••",
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 40),

            // Gradient Reset Button
            ModernButton(
              text: "Reset Password",
              onPressed: isLoading ? null : resetPassword,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

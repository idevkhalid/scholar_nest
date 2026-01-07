import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import '../constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fNameCtrl = TextEditingController();
  final TextEditingController lNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool _isLoading = false;

  // 1. ADDED: State variables for independent toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    fNameCtrl.dispose();
    lNameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (passCtrl.text != confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.register(
        fName: fNameCtrl.text.trim(),
        lName: lNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        passwordConfirmation: confirmPassCtrl.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: emailCtrl.text.trim(),
              firstName: fNameCtrl.text.trim(),
              lastName: lNameCtrl.text.trim(),
              password: passCtrl.text.trim(),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),

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
                  // --- Heading ---
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign up to start your journey',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Form Card ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
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
                            controller: fNameCtrl,
                            label: 'First Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: lNameCtrl,
                            label: 'Last Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          // 2. PASSWORD FIELD (With Toggle)
                          _buildTextField(
                            controller: passCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureTextState: _obscurePassword, // Pass current state
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // 3. CONFIRM PASSWORD FIELD (With Toggle)
                          _buildTextField(
                            controller: confirmPassCtrl,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureTextState: _obscureConfirmPassword, // Pass current state
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // --- Sign Up Button ---
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
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.textPrimary),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Sign in",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
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
        ),
      ),
    );
  }

  // 4. UPDATED HELPER METHOD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isPassword = false, // Flag to identify password fields
    bool? obscureTextState,  // The specific boolean for this field
    VoidCallback? onToggleVisibility, // The specific toggle function
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Determine the actual obscure state
    // If it's a password field, use the passed state. Otherwise, false.
    final bool isObscured = isPassword ? (obscureTextState ?? true) : false;

    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,

        // Add Eye Icon if it is a password field
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        )
            : null,

        border: OutlineInputBorder(
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
        if ((label == 'Password' || label == 'Confirm Password') && v.length < 4) {
          return 'Too short';
        }
        if (label == 'Email' && !v.contains('@')) return 'Enter valid email';
        return null;
      },
    );
  }
}
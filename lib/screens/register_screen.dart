import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fnCtrl = TextEditingController();
  final lnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    fnCtrl.dispose();
    lnCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final response = await authProvider.register(
        fName: fnCtrl.text.trim(),
        lName: lnCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        passwordConfirmation: confirmCtrl.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        // Navigate to OTP Verification Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: emailCtrl.text.trim(),
              firstName: fnCtrl.text.trim(),
              lastName: lnCtrl.text.trim(),
              password: passCtrl.text,
            ),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1B3C53);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.jpeg', width: 140, height: 140),
              const SizedBox(height: 8),
              const Text('HEY! Welcome to ScholarNest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fnCtrl,
                          decoration: _inputDecoration('First Name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter first name' : null,
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: lnCtrl,
                          decoration: _inputDecoration('Last Name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter last name' : null,
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: emailCtrl,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter email';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: passCtrl,
                          decoration: _inputDecoration('Password'),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 4) return 'Password too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: confirmCtrl,
                          decoration: _inputDecoration('Confirm Password'),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm password';
                            if (v != passCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('NEXT', style: TextStyle(fontSize: 16,color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(onPressed: () {}, child: const Text('Terms & Conditions')),
                            const SizedBox(width: 6),
                            TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}

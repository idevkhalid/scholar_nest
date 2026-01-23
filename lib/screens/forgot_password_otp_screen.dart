import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import 'home_screen.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/modern_button.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;

  const SetNewPasswordScreen({super.key, required this.email});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final List<TextEditingController> _otpCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  bool _resending = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes[0].requestFocus());
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) c.dispose();
    for (final n in _nodes) n.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  String get _enteredOtp => _otpCtrls.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  Future<void> _confirm() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
      return;
    }
    if (newPassCtrl.text.isEmpty || confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter new password')));
      return;
    }
    if (newPassCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.resetPassword(
      email: widget.email,
      otp: _enteredOtp,
      password: newPassCtrl.text,
      passwordConfirmation: confirmPassCtrl.text,
    );

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Your password has been reset successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Verification failed')),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);

    final response = await ApiService.resendOtp(widget.email);

    setState(() => _resending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'OTP resent')),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      width: width * 0.2,
                      height: width * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Heading
                  const Text(
                    'Set New Password',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Modern OTP Boxes (Responsive)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                                (i) => Flexible(
                              child: _gradientOtpBox(_otpCtrls[i], _nodes[i], i),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // New Password
                        ModernTextField(
                          controller: newPassCtrl,
                          labelText: "New Password",
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password
                        ModernTextField(
                          controller: confirmPassCtrl,
                          labelText: "Confirm Password",
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),

                        // Confirm Button
                        ModernButton(
                          text: "Confirm",
                          onPressed: _isLoading ? null : _confirm,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 15),
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

  // Gradient OTP Box
  Widget _gradientOtpBox(TextEditingController ctrl, FocusNode node, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: node.hasFocus
            ? AppColors.primaryGradient
            : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade100]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: ctrl,
          focusNode: node,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary), // Added color
          decoration: const InputDecoration(counterText: '', border: InputBorder.none),
          onChanged: (v) => _onOtpChanged(index, v),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }


}

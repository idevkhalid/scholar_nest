import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'verified_screen.dart';
import '../constants/colors.dart'; // AppColors

class VerificationScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _resending = false;

  // Define the dark blue color for Text/Buttons
  final Color _darkBlue = const Color(0xFF1B3C53);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _enteredOtp => _otpCtrls.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _confirm() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
      return;
    }

    setState(() => _isLoading = true);

    final response =
    await ApiService.verifyOtp(email: widget.email, otp: _enteredOtp);

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false)
            .login(widget.firstName, widget.email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifiedScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Verification failed')),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);

    final response = await ApiService.resendOtp(widget.email);

    setState(() => _resending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'OTP resent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = (screenWidth - 80) / 6;

    return Scaffold(
      body: Container(
        // --- UPDATED GRADIENT ---
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF90CAF9), // Darker Blue at the top
              Colors.white,      // Whitish at the bottom
            ],
          ),
        ),
        // ------------------------
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // --- LOGO ---
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      width: screenWidth * 0.4,
                      height: screenWidth * 0.4,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Verification',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _darkBlue),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Enter the 6-digit code sent to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: _darkBlue.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                        6, (i) => _otpBox(_otpCtrls[i], _nodes[i], i, boxSize)),
                  ),
                  const SizedBox(height: 50),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: _darkBlue.withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend Button
                  TextButton(
                    onPressed: _resending ? null : _resendOtp,
                    child: _resending
                        ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: _darkBlue, strokeWidth: 2))
                        : Text.rich(
                      TextSpan(
                        text: "Didn't receive the code? ",
                        style: TextStyle(
                            color: _darkBlue.withOpacity(0.7)),
                        children: [
                          TextSpan(
                            text: "Resend",
                            style: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
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

  Widget _otpBox(
      TextEditingController ctrl, FocusNode node, int index, double size) {
    final isFocused = node.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size + 15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? _darkBlue : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: ctrl,
          focusNode: node,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: _darkBlue),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onOtpChanged(index, v),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }
}
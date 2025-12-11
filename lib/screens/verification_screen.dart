import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'verified_screen.dart';
import '../constants/colors.dart'; // import AppColors

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
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _resending = false;

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
  }

  Future<void> _confirm() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.verifyOtp(email: widget.email, otp: _enteredOtp);

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      Provider.of<AuthProvider>(context, listen: false).login(widget.firstName, widget.email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifiedScreen()),
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
    const primary = Color(0xFF1B3C53);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient, // apply gradient
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// LOGO
                ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.asset(
                    'assets/logo.jpeg',
                    width: 150,
                    height: 150,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'VERIFICATION CODE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // updated for theme consistency
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'We sent a verification code to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary?.withOpacity(0.8),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                /// OTP BOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _otpCtrls[i],
                        focusNode: _nodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(i, v),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                /// CONFIRM BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Confirm Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _resending ? null : _resendOtp,
                  child: _resending
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : const Text(
                    "Didn't receive the code? Resend",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

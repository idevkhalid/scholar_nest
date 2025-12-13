import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';
import '../constants/colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _otpCtrls) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  String get _enteredOtp => _otpCtrls.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_nodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_nodes[index - 1]);
    }
  }

  Future<void> verifyOtp() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter 6-digit OTP')));
      return;
    }

    setState(() => isLoading = true);

    final response =
    await ApiService.verifyOtp(email: widget.email, otp: _enteredOtp);

    setState(() => isLoading = false);

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('OTP verified successfully')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, otp: _enteredOtp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Invalid OTP')),
      );
    }
  }

  Future<void> resendOtp() async {
    setState(() => isResending = true);

    final response = await ApiService.resendOtp(widget.email);

    setState(() => isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'Failed to resend OTP')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // important to prevent overflow
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Circular Logo
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Heading
                        Text(
                          "OTP Verification",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtext
                        Text(
                          "Enter the 6-digit OTP sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary?.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // OTP Boxes Row
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
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                    BorderSide(color: Colors.white.withOpacity(0.4)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                ),
                                onChanged: (v) => _onOtpChanged(i, v),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            );
                          }).map((widget) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: widget,
                          )).toList(),
                        ),

                        const SizedBox(height: 30),

                        Spacer(), // pushes button up when keyboard is open

                        // VERIFY Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : verifyOtp,
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
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  "VERIFY OTP",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // RESEND OTP
                        TextButton(
                          onPressed: isResending ? null : resendOtp,
                          child: isResending
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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
}

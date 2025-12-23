import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';
import 'home_screen.dart';

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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
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
                        const SizedBox(height: 25),

                        // New Password
                        _passwordField(
                          "New Password",
                          newPassCtrl,
                          _showNewPass,
                              () => setState(() => _showNewPass = !_showNewPass),
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password
                        _passwordField(
                          "Confirm Password",
                          confirmPassCtrl,
                          _showConfirmPass,
                              () => setState(() => _showConfirmPass = !_showConfirmPass),
                        ),
                        const SizedBox(height: 25),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _confirm,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  'Confirm',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(counterText: '', border: InputBorder.none),
          onChanged: (v) => _onOtpChanged(index, v),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController ctrl, bool visible, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary)),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Colors.black),
          onPressed: toggle,
        ),
      ),
    );
  }
}

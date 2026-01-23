import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onFieldSubmitted,
    this.onChanged,
    this.textInputAction,
  });

  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2C40).withValues(alpha: 0.05), // Deep navy shadow, very subtle
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscure : false,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        maxLines: widget.maxLines,
        onFieldSubmitted: widget.onFieldSubmitted,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        style: const TextStyle(
          fontWeight: FontWeight.w500, 
          color: AppColors.textPrimary,
          fontFamily: 'Inter', // High legibility for input
        ),
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          alignLabelWithHint: widget.maxLines > 1,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Inter'),
          labelStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Inter'),
          filled: true,
          fillColor: Colors.transparent, // Handled by Container
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppColors.primary.withValues(alpha: 0.7), size: 22)
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5), // Gold Focus Border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}

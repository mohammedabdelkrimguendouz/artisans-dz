import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final bool enabled;
  final String? labelText;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.labelText,
    this.textInputAction,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.right,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: const TextStyle(
          color: AppColors.textLight,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          height: 0.8,
        ),
        errorMaxLines: 2,
        counterText: '',
      ),
      validator: validator,
    );
  }
}
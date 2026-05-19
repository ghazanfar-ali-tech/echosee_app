import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;
  final int? radius;
  final bool obscureText;
  final bool isDark;
  final Color? primaryColor;
  final Color? borderColor;
  final Color? hintColor;
  final Color? iconColor;
  final Color? fillColor;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.onTap,
    this.onSuffixTap,
    this.radius,
    this.obscureText = false,
    this.isDark = true,
    this.primaryColor,
    this.borderColor,
    this.hintColor,
    this.iconColor,
    this.fillColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if (value!.isEmpty) {
          return "Enter Password";
        }
        return null;
      },
      style: TextStyle(
        color: isDark ? const Color(0xFFE8F4F8) : const Color(0xFF0A1628),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color:
              hintColor ??
              (isDark ? const Color(0xFF4A6280) : const Color(0xFF7A9BB5)),
          fontSize: 14,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.blue, size: 20),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color:
                      iconColor ??
                      (isDark
                          ? const Color(0xFF4A6280)
                          : const Color(0xFF7A9BB5)),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor:
            fillColor ??
            (isDark ? const Color(0xFF0D1421) : const Color(0xFFFFFFFF)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius?.toDouble() ?? 12),
          borderSide: BorderSide(
            color:
                borderColor ??
                (isDark ? const Color(0xFF1E2D42) : const Color(0xFFD0E4F7)),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius?.toDouble() ?? 12),
          borderSide: BorderSide(
            color:
                borderColor ??
                (isDark ? const Color(0xFF1E2D42) : const Color(0xFFD0E4F7)),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius?.toDouble() ?? 12),
          borderSide: BorderSide(
            color: primaryColor ?? const Color(0xFF00D4FF),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

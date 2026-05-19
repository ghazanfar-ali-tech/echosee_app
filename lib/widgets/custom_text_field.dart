import 'package:flutter/material.dart';

Widget customTextField({
  required String hintText,
  required IconData prefixIcon,
  IconData? suffixIcon,
  required TextEditingController controller,
  VoidCallback? onTap,
  int? radius,
  bool obscureText = false,
  bool isDark = true,
  Color? primaryColor,
  Color? borderColor,
  Color? hintColor,
  Color? iconColor,
  Color? fillColor,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
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
      prefixIcon: Icon(
        prefixIcon,
        color:
            iconColor ??
            (isDark ? const Color(0xFF4A6280) : const Color(0xFF7A9BB5)),
        size: 20,
      ),
      suffixIcon: suffixIcon != null
          ? GestureDetector(
              onTap: onTap,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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

import 'package:flutter/material.dart';

Widget roundedButton({
  required String text,
  required VoidCallback? onTap,
  required IconData icon,
  int? radius,
  bool isLoading = false,
  EdgeInsetsGeometry? padding,
  List<Color>? gradientColors,
  Color? borderColor,
  Color? textColor,
  Widget? leadingWidget,
  bool useGradient = true,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius?.toDouble() ?? 12),
        color: !useGradient
            ? (gradientColors?.isNotEmpty == true
                  ? gradientColors!.first
                  : const Color(0xFF00D4FF))
            : null,
        gradient: useGradient
            ? LinearGradient(
                colors:
                    gradientColors ??
                    [const Color(0xFF00D4FF), const Color(0xFF7B2FBE)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
    ),
  );
}

import 'package:flutter/material.dart';

Widget roundedButton({
  required String text,
  required VoidCallback onTap,
  required IconData icon,
  int? radius,
  EdgeInsetsGeometry? padding,
  List<Color>? gradientColors,
  Color? borderColor,
  Color? textColor,
  Widget? leadingWidget,
  bool useGradient = true,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius?.toDouble() ?? 12),
        color: !useGradient 
            ? (gradientColors?.isNotEmpty == true ? gradientColors!.first : const Color(0xFF00D4FF))
            : null,
        gradient: useGradient
            ? LinearGradient(
                colors: gradientColors ??
                    [const Color(0xFF00D4FF), const Color(0xFF7B2FBE)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: Row(
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

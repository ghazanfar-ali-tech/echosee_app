import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildLogo(bool isDark, Color primaryColor, Color subText, Size size) {
  return Column(
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Echo',

              style: GoogleFonts.orbitron(
                color: isDark
                    ? const Color(0xFFE8F4F8)
                    : const Color(0xFF0A1628),
                fontSize: size.width * 0.075,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            TextSpan(
              text: 'See',
              style: GoogleFonts.orbitron(
                color: primaryColor,
                fontSize: size.width * 0.075,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: size.height * 0.008),
      Text(
        'Break Barriers, Hear The World',
        style: TextStyle(
          color: subText,
          fontSize: size.width * 0.034,
          letterSpacing: 0.3,
        ),
      ),
    ],
  );
}

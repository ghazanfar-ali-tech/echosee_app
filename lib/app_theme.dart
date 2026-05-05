// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Palette - Deep Navy/Cyan tech aesthetic
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0096C7);
  static const Color accent = Color(0xFF7B2FBE);
  static const Color accentGlow = Color(0xFFAA5FE8);

  // Dark Theme
  static const Color darkBg = Color(0xFF050A14);
  static const Color darkSurface = Color(0xFF0D1421);
  static const Color darkCard = Color(0xFF121D2E);
  static const Color darkCardHover = Color(0xFF1A2640);
  static const Color darkBorder = Color(0xFF1E2D42);
  static const Color darkText = Color(0xFFE8F4F8);
  static const Color darkTextSub = Color(0xFF7A9BB5);
  static const Color darkTextMuted = Color(0xFF4A6280);

  // Light Theme
  static const Color lightBg = Color(0xFFF0F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD0E4F7);
  static const Color lightText = Color(0xFF0A1628);
  static const Color lightTextSub = Color(0xFF3D6080);
  static const Color lightTextMuted = Color(0xFF7A9BB5);

  // Semantic
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF4757);
  static const Color offline = Color(0xFFFF6B35);

  // Speaker Colors
  static const Color speaker1 = Color(0xFF00D4FF);
  static const Color speaker2 = Color(0xFFFF6EC7);
  static const Color speaker3 = Color(0xFF7BFF6E);
  static const Color speaker4 = Color(0xFFFFD700);

  // Subtitle Background
  static const Color subtitleBgDark = Color(0xCC050A14);
  static const Color subtitleBgLight = Color(0xDDFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D1421), Color(0xFF121D2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x2200D4FF), Color(0x007B2FBE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.darkBg,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
    ),
    textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextSub),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: AppColors.darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.darkTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withOpacity(0.3);
        }
        return AppColors.darkBorder;
      }),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.darkBorder,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x2200D4FF),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
    ),
    textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextSub),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 2,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 1.5,
      ),
      headlineLarge: GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 1,
      ),
      headlineMedium: GoogleFonts.rajdhani(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.5,
      ),
      titleLarge: GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

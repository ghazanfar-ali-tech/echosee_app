import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AppThemeColors {
  final bool isDark;
  final Color bgColor;
  final Color cardColor;
  final Color cardBorder;
  final Color primaryText;
  final Color subText;
  final Color primaryColor;

  AppThemeColors({
    required this.isDark,
    required this.bgColor,
    required this.cardColor,
    required this.cardBorder,
    required this.primaryText,
    required this.subText,
    required this.primaryColor,
  });
}

class AppConstants {
  static AppThemeColors getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF050A14) : const Color(0xFFF0F7FF);
    final cardColor = isDark
        ? const Color(0xFF0D1421)
        : const Color(0xFFFFFFFF);
    final cardBorder = isDark
        ? const Color(0xFF1E2D42)
        : const Color(0xFFD0E4F7);
    final primaryText = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0096C7);
    final subText = isDark ? const Color(0xFF7A9BB5) : const Color(0xFF3D6080);
    final primaryColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF0096C7);
        
    return AppThemeColors(
      isDark: isDark,
      bgColor: bgColor,
      cardColor: cardColor,
      cardBorder: cardBorder,
      primaryText: primaryText,
      subText: subText,
      primaryColor: primaryColor,
    );
  }

  // App Info
  static const String appName = 'EchoSee';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'See Every Word';

  // Database
  static const String dbName = 'echosee.db';
  static const int dbVersion = 1;
  static const String transcriptsTable = 'transcripts';
  static const String settingsTable = 'settings';
  static const String subtitlesTable = 'subtitles';

  // Transcript limits
  static const int freeTranscriptLimit = 5;

  // Bluetooth
  static const String esp32ServiceUUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String esp32TxCharUUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String esp32RxCharUUID = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String glassesDeviceName = 'EchoSee';
  static const int btScanTimeout = 10; // seconds

  // Speech to Text
  static const int subtitleFadeInMs = 300;
  static const int subtitleSlideUpMs = 400;
  static const int subtitleHoldMs = 4000;

  // Languages
  static const List<Map<String, String>> freeLanguages = [
    {
      'code': 'en-US',
      'name': 'English',
      'flag': '🇺🇸',
      'nativeName': 'English',
    },
    {'code': 'ur-PK', 'name': 'Urdu', 'flag': '🇵🇰', 'nativeName': 'اردو'},
  ];

  static const List<Map<String, String>> premiumLanguages = [
    {
      'code': 'ar-SA',
      'name': 'Arabic',
      'flag': '🇸🇦',
      'nativeName': 'العربية',
    },
    {
      'code': 'fr-FR',
      'name': 'French',
      'flag': '🇫🇷',
      'nativeName': 'Français',
    },
    {'code': 'zh-CN', 'name': 'Chinese', 'flag': '🇨🇳', 'nativeName': '中文'},
    {
      'code': 'es-ES',
      'name': 'Spanish',
      'flag': '🇪🇸',
      'nativeName': 'Español',
    },
  ];

  // Subtitle Positions
  static const String positionTop = 'top';
  static const String positionCenter = 'center';
  static const String positionBottom = 'bottom';

  // Font Sizes
  static const double fontSmall = 14.0;
  static const double fontMedium = 18.0;
  static const double fontLarge = 24.0;
  static const double fontXLarge = 30.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // Settings Keys
  static const String keyDarkMode = 'dark_mode';
  static const String keyFontSize = 'font_size';
  static const String keySubtitlePosition = 'subtitle_position';
  static const String keySubtitleColor = 'subtitle_color';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyIsPremium = 'is_premium';
  static const String keyOnboardingDone = 'onboarding_done';
}

class AppRoutes {
  static const String bluetoothOnboarding = '/bluetooth-onboarding';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String subtitles = '/subtitles';
  static const String transcripts = '/transcripts';
  static const String transcriptDetail = '/transcript-detail';
  static const String settings = '/settings';
  static const String bluetooth = '/bluetooth';
  static const String premium = '/premium';
  static const String profile = '/profile';
  static const String yamnet = '/yamnet';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
}

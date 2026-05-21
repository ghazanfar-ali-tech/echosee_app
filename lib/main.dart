import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/bluetooth_screen.dart';
import 'package:echosee_app/constants.dart';
import 'package:echosee_app/home_screen.dart';
import 'package:echosee_app/login_screen.dart';
import 'package:echosee_app/provider/auth_providers/login_provider.dart';
import 'package:echosee_app/provider/auth_providers/signup_provider.dart';
import 'package:echosee_app/provider/bluetooth_provider.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/sub_title_provider.dart';
import 'package:echosee_app/provider/trans_script_provider.dart';
import 'package:echosee_app/signup_screen.dart';
import 'package:echosee_app/splash_screen.dart';
import 'package:echosee_app/terms_of_service_screen.dart';
import 'package:echosee_app/privacy_policy_screen.dart';
import 'package:echosee_app/forgot_password_screen.dart';
import 'package:echosee_app/yamnet_module/yamnet_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Constants.apiKey,
      appId: Constants.appId,
      messagingSenderId: Constants.messagingSenderId,
      projectId: Constants.projectId,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final savedDarkMode = prefs.getBool('dark_mode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(initialDarkMode: savedDarkMode),
        ),
        ChangeNotifierProvider(create: (_) => SubtitleProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: sp.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.bluetooth: (context) => const BluetoothHomePage(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.yamnet: (context) => const YamnetScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.termsOfService: (context) => const TermsOfServiceScreen(),
        AppRoutes.privacyPolicy: (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}

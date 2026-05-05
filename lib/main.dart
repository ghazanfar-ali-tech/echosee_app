import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/home_screen.dart';
import 'package:echosee_app/provider/bluetooth_provider.dart';
import 'package:echosee_app/provider/setting_provider.dart';
import 'package:echosee_app/provider/sub_title_provider.dart';
import 'package:echosee_app/provider/trans_script_provider.dart';
import 'package:echosee_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SubtitleProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Defaulting to dark for tech aesthetic
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        // Add other routes as needed
      },
    );
  }
}

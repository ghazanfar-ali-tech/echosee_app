import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

class AppTranslator {
  static String _currentLanguage = 'en';

  static final Map<String, Map<String, String>> _translations = {
    'en': {'hello_how_are_you': 'Hello, how are you?'},
    'ur': {'hello_how_are_you': 'ہیلو، آپ کیسے ہیں؟'},
  };

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String langCode) {
    _currentLanguage = langCode;
  }

  static String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }
}

// Short alias
String tr(String key) => AppTranslator.translate(key);

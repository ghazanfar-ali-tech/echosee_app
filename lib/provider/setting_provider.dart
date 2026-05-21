import 'package:echosee_app/models/model.dart';
import 'package:echosee_app/repositries/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  static const String _darkModeKey = 'dark_mode';

  late SettingsModel _settings;

  SettingsProvider({
    SettingsRepository? repository,
    bool initialDarkMode = false, // ← new param
  }) : _repository = repository ?? SettingsRepository() {
    // Set dark mode immediately — no async gap, no flash
    _settings = SettingsModel(isDarkMode: initialDarkMode);
    _loadOtherSettings();
  }

  bool get isDarkMode => _settings.isDarkMode;
  double get fontSize => _settings.fontSize;
  String get subtitlePosition => _settings.subtitlePosition;
  int get subtitleColor => _settings.subtitleColor;
  String get selectedLanguage => _settings.selectedLanguage;
  bool get isPremium => _settings.isPremium;

  // Load SQLite settings without touching dark mode
  Future<void> _loadOtherSettings() async {
    final settings = await _repository.getSettings();
    // Preserve the already-correct dark mode value
    _settings = settings.copyWith(isDarkMode: _settings.isDarkMode);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final newValue = !_settings.isDarkMode;
    _settings = _settings.copyWith(isDarkMode: newValue);
    notifyListeners(); // instant UI update

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, newValue);
  }

  Future<void> setDarkMode(bool value) async {
    if (_settings.isDarkMode == value) return;
    _settings = _settings.copyWith(isDarkMode: value);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    notifyListeners();
    await _repository.updateSetting('font_size', size);
  }

  Future<void> setSubtitlePosition(String position) async {
    _settings = _settings.copyWith(subtitlePosition: position);
    notifyListeners();
    await _repository.updateSetting('subtitle_position', position);
  }

  Future<void> setSubtitleColor(int color) async {
    _settings = _settings.copyWith(subtitleColor: color);
    notifyListeners();
    await _repository.updateSetting('subtitle_color', color);
  }

  Future<void> setSelectedLanguage(String language) async {
    _settings = _settings.copyWith(selectedLanguage: language);
    notifyListeners();
    await _repository.updateSetting('selected_language', language);
  }

  Future<void> setIsPremium(bool value) async {
    _settings = _settings.copyWith(isPremium: value);
    notifyListeners();
    await _repository.updateSetting('is_premium', value);
  }

  // In SettingsProvider — add this public method
  Future<void> loadSettings() async {
    final settings = await _repository.getSettings();
    // Preserve the already-correct dark mode from SharedPreferences
    _settings = settings.copyWith(isDarkMode: _settings.isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(selectedLanguage: language);
    notifyListeners();
    await _repository.updateSetting('selected_language', language);
  }
}

import 'package:echosee_app/models/model.dart';
import 'package:echosee_app/repositries/setting_repo.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo;
  SettingsModel _settings = const SettingsModel();
  bool _isLoading = false;

  SettingsProvider({SettingsRepository? repo})
    : _repo = repo ?? SettingsRepository();

  SettingsModel get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  double get fontSize => _settings.fontSize;
  String get subtitlePosition => _settings.subtitlePosition;
  Color get subtitleColor => Color(_settings.subtitleColor);
  String get selectedLanguage => _settings.selectedLanguage;
  bool get isPremium => _settings.isPremium;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _repo.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setSubtitlePosition(String position) async {
    _settings = _settings.copyWith(subtitlePosition: position);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setSubtitleColor(Color color) async {
    _settings = _settings.copyWith(subtitleColor: color.value);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }

  Future<void> setLanguage(String languageCode) async {
    _settings = _settings.copyWith(selectedLanguage: languageCode);
    notifyListeners();
    await _repo.saveSettings(_settings);
  }
}

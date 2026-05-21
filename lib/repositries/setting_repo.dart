import 'package:echosee_app/data_base/sqlite_db.dart';
import 'package:echosee_app/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final DatabaseHelper _db;
  static const String _darkModeKey = 'dark_mode';

  SettingsRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<SettingsModel> getSettings() async {
    final map = await _db.getSettings();
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;

    if (map == null) return SettingsModel(isDarkMode: isDarkMode);
    return SettingsModel.fromMap(map).copyWith(isDarkMode: isDarkMode);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    // Save dark mode to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, settings.isDarkMode);

    // Save everything else to SQLite
    await _db.updateSettings(settings.toMap());
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final current = await getSettings();
    late SettingsModel updated;

    switch (key) {
      case 'dark_mode':
        // Save only to SharedPreferences, skip SQLite for this key
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_darkModeKey, value as bool);
        return;
      case 'font_size':
        updated = current.copyWith(fontSize: value as double);
        break;
      case 'subtitle_position':
        updated = current.copyWith(subtitlePosition: value as String);
        break;
      case 'subtitle_color':
        updated = current.copyWith(subtitleColor: value as int);
        break;
      case 'selected_language':
        updated = current.copyWith(selectedLanguage: value as String);
        break;
      case 'is_premium':
        updated = current.copyWith(isPremium: value as bool);
        break;
      default:
        return;
    }

    await saveSettings(updated);
  }
}

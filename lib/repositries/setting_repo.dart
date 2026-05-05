import 'package:echosee_app/data_base/sqlite_db.dart';
import 'package:echosee_app/models/model.dart';

class SettingsRepository {
  final DatabaseHelper _db;

  SettingsRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper();

  Future<SettingsModel> getSettings() async {
    final map = await _db.getSettings();
    if (map == null) return const SettingsModel();
    return SettingsModel.fromMap(map);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _db.updateSettings(settings.toMap());
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final current = await getSettings();
    late SettingsModel updated;

    switch (key) {
      case 'dark_mode':
        updated = current.copyWith(isDarkMode: value as bool);
        break;
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

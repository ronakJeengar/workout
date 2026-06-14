import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_settings.dart';
import 'settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  final SharedPreferences _prefs;

  static const _themeKey = 'settings_theme';
  static const _unitsKey = 'settings_units';
  static const _restKey = 'settings_rest';
  static const _localeKey = 'settings_locale';

  LocalSettingsRepository(this._prefs);

  @override
  Future<AppSettings> getSettings() async {
    try {
      final themeIndex = _prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      final unitsIndex = _prefs.getInt(_unitsKey) ?? UnitSystem.kg.index;
      final restSeconds = _prefs.getInt(_restKey) ?? 60;
      final locale = _prefs.getString(_localeKey);

      return AppSettings(
        themeMode: _safeEnumValue(AppThemeMode.values, themeIndex, AppThemeMode.system),
        unitSystem: _safeEnumValue(UnitSystem.values, unitsIndex, UnitSystem.kg),
        defaultRestSeconds: restSeconds.clamp(30, 300),
        locale: locale,
      );
    } catch (e) {
      return AppSettings.defaultSettings();
    }
  }

  T _safeEnumValue<T>(List<T> values, int index, T defaultValue) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return defaultValue;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setInt(_themeKey, settings.themeMode.index);
    await _prefs.setInt(_unitsKey, settings.unitSystem.index);
    await _prefs.setInt(_restKey, settings.defaultRestSeconds);
    if (settings.locale != null) {
      await _prefs.setString(_localeKey, settings.locale!);
    } else {
      await _prefs.remove(_localeKey);
    }
  }
}

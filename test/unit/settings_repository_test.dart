import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/features/settings/data/local_settings_repository.dart';
import 'package:workout/features/settings/domain/app_settings.dart';

void main() {
  group('LocalSettingsRepository', () {
    late SharedPreferences prefs;
    late LocalSettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = LocalSettingsRepository(prefs);
    });

    test('getSettings returns defaults when no data', () async {
      final settings = await repository.getSettings();
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.unitSystem, UnitSystem.kg);
      expect(settings.defaultRestSeconds, 60);
    });

    test('recovers from out-of-bounds enum index', () async {
      await prefs.setInt('settings_theme', 99);
      final settings = await repository.getSettings();
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('clamps invalid rest timer values', () async {
      await prefs.setInt('settings_rest', 10); // below min
      var settings = await repository.getSettings();
      expect(settings.defaultRestSeconds, 30);

      await prefs.setInt('settings_rest', 500); // above max
      settings = await repository.getSettings();
      expect(settings.defaultRestSeconds, 300);
    });
  });
}

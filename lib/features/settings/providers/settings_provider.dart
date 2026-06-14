import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(AppSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _repository.getSettings();
  }

  Future<void> updateTheme(AppThemeMode themeMode) async {
    final newSettings = state.copyWith(themeMode: themeMode);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateUnits(UnitSystem unitSystem) async {
    final newSettings = state.copyWith(unitSystem: unitSystem);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateDefaultRest(int seconds) async {
    final newSettings = state.copyWith(defaultRestSeconds: seconds);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateLocale(String? locale) async {
    final newSettings = state.copyWith(locale: locale);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

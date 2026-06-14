enum AppThemeMode { system, light, dark }
enum UnitSystem { kg, lb }

class AppSettings {
  final AppThemeMode themeMode;
  final UnitSystem unitSystem;
  final int defaultRestSeconds;
  final String? locale;

  const AppSettings({
    required this.themeMode,
    required this.unitSystem,
    required this.defaultRestSeconds,
    this.locale,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    UnitSystem? unitSystem,
    int? defaultRestSeconds,
    String? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      unitSystem: unitSystem ?? this.unitSystem,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      locale: locale ?? this.locale,
    );
  }

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      themeMode: AppThemeMode.system,
      unitSystem: UnitSystem.kg,
      defaultRestSeconds: 60,
      locale: null,
    );
  }
}

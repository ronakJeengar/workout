import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/app_config.dart';
import 'core/monitoring/crash_triage.dart';
import 'core/monitoring/data_integrity_service.dart';
import 'features/calendar/data/local_calendar_repository.dart';
import 'features/calendar/providers/calendar_providers.dart';
import 'features/goals/data/local_goal_repository.dart';
import 'features/goals/providers/goal_providers.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/programs/data/local_program_repository.dart';
import 'features/programs/providers/program_providers.dart';
import 'features/settings/data/local_settings_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/workout/data/local_storage_workout_repository.dart';
import 'features/workout/providers/workout_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.log('App starting...');

  final prefs = await SharedPreferences.getInstance();
  AppConfig.log('SharedPreferences initialized');

  final crashTriage = CrashTriageService(prefs);
  final watchdog = DataIntegrityService(crashTriage);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashTriage.reportCrash(
      details.exceptionAsString(),
      details.stack?.toString() ?? '',
      reason: 'FlutterError: ${details.context}',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    crashTriage.reportCrash(
      error.toString(),
      stack.toString(),
      reason: 'PlatformDispatcherError',
    );
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        workoutRepositoryProvider.overrideWithValue(
          LocalStorageWorkoutRepository(prefs, watchdog),
        ),
        settingsRepositoryProvider.overrideWithValue(
          LocalSettingsRepository(prefs),
        ),
        programRepositoryProvider.overrideWithValue(
          LocalProgramRepository(prefs),
        ),
        goalRepositoryProvider.overrideWithValue(
          LocalGoalRepository(prefs),
        ),
        calendarRepositoryProvider.overrideWithValue(
          LocalCalendarRepository(prefs),
        ),
        profileProvider.overrideWith((ref) => ProfileNotifier(prefs)),
      ],
      child: const WorkoutApp(),
    ),
  );
  AppConfig.log('App initialized and running');
}

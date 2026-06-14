import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'app.dart';
import 'core/app_config.dart';
import 'core/database.dart';
import 'core/monitoring/crash_triage.dart';
import 'core/monitoring/data_integrity_service.dart';
import 'features/calendar/data/local_calendar_repository.dart';
import 'features/calendar/providers/calendar_providers.dart';
import 'features/goals/data/local_goal_repository.dart';
import 'features/goals/providers/goal_providers.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/profile/data/isar_body_weight_entry.dart';
import 'features/programs/data/local_program_repository.dart';
import 'features/programs/providers/program_providers.dart';
import 'features/programs/data/isar_program.dart';
import 'features/settings/data/local_settings_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/workout/data/local_storage_workout_repository.dart';
import 'features/workout/providers/workout_providers.dart';
import 'features/workout/data/isar_workout.dart';
import 'features/workout/data/isar_workout_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.log('App starting...');

  final prefs = await SharedPreferences.getInstance();
  AppConfig.log('SharedPreferences initialized');

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      IsarWorkoutSchema,
      IsarWorkoutSessionSchema,
      IsarProgramSchema,
      IsarWorkoutNoteSchema,
      IsarBodyWeightEntrySchema,
    ],
    directory: dir.path,
  );
  AppConfig.log('Isar initialized');

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
        isarProvider.overrideWithValue(isar),
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

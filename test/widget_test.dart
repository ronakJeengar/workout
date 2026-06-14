import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/app.dart';
import 'package:workout/features/calendar/data/calendar_repository.dart';
import 'package:workout/features/calendar/domain/scheduled_day.dart';
import 'package:workout/features/calendar/providers/calendar_providers.dart';
import 'package:workout/features/goals/data/goal_repository.dart';
import 'package:workout/features/goals/domain/goal.dart';
import 'package:workout/features/goals/providers/goal_providers.dart';
import 'package:workout/features/profile/providers/profile_providers.dart';
import 'package:workout/features/programs/data/program_repository.dart';
import 'package:workout/features/programs/domain/program.dart';
import 'package:workout/features/programs/providers/program_providers.dart';
import 'package:workout/features/settings/providers/settings_provider.dart';
import 'package:workout/features/workout/providers/workout_providers.dart';
import 'package:workout/features/settings/domain/app_settings.dart';
import 'package:workout/features/settings/data/settings_repository.dart';
import 'package:workout/features/workout/data/workout_repository.dart';
import 'package:workout/features/workout/domain/workout.dart';
import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/core/monitoring/crash_triage.dart';

class MockSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async => AppSettings.defaultSettings();
  @override
  Future<void> saveSettings(AppSettings settings) async {}
}

class MockWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<Workout>> getWorkouts() async => [];
  @override
  Future<void> createWorkout(Workout workout) async {}
  @override
  Future<void> updateWorkout(Workout workout) async {}
  @override
  Future<void> deleteWorkout(String id) async {}
  @override
  Future<void> startSession(WorkoutSession session) async {}
  @override
  Future<void> endSession(WorkoutSession session) async {}
  @override
  Future<List<WorkoutSession>> getSessionHistory() async => [];
  @override
  Future<WorkoutSession?> getActiveSession() async => null;
  @override
  Future<void> saveActiveSession(WorkoutSession? session) async {}
}

class MockProgramRepository implements ProgramRepository {
  @override
  Future<List<Program>> getPrograms() async => [];
  @override
  Future<void> createProgram(Program program) async {}
  @override
  Future<void> updateProgram(Program program) async {}
  @override
  Future<void> deleteProgram(String id) async {}
}

class MockGoalRepository implements GoalRepository {
  @override
  Future<List<Goal>> getGoals() async => [];
  @override
  Future<void> saveGoal(Goal goal) async {}
  @override
  Future<void> deleteGoal(String id) async {}
  @override
  Future<List<Achievement>> getAchievements() async => [];
  @override
  Future<void> saveAchievement(Achievement achievement) async {}
}

class MockCalendarRepository implements CalendarRepository {
  @override
  Future<List<ScheduledDay>> getSchedule() async => [];
  @override
  Future<void> saveScheduledDay(ScheduledDay day) async {}
  @override
  Future<void> deleteScheduledDay(DateTime date) async {}
}

void main() {
  testWidgets('App starts at home screen', (WidgetTester tester) async {
    // Set larger surface size to prevent dashboard overflow in tests
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(MockSettingsRepository()),
          workoutRepositoryProvider.overrideWithValue(MockWorkoutRepository()),
          programRepositoryProvider.overrideWithValue(MockProgramRepository()),
          goalRepositoryProvider.overrideWithValue(MockGoalRepository()),
          calendarRepositoryProvider.overrideWithValue(MockCalendarRepository()),
          profileProvider.overrideWith((ref) => ProfileNotifier(prefs)),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that our home screen text is present.
    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets("Today's Intelligence Card renders and triggers recommended workout", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(MockSettingsRepository()),
          workoutRepositoryProvider.overrideWithValue(MockWorkoutRepository()),
          programRepositoryProvider.overrideWithValue(MockProgramRepository()),
          goalRepositoryProvider.overrideWithValue(MockGoalRepository()),
          calendarRepositoryProvider.overrideWithValue(MockCalendarRepository()),
          profileProvider.overrideWith((ref) => ProfileNotifier(prefs)),
        ],
        child: const WorkoutApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Today's Intelligence card header is present
    expect(find.text("TODAY'S INTELLIGENCE"), findsOneWidget);
    // Verify introductory recommendation is shown
    expect(find.text("INTRODUCTORY SPLIT"), findsOneWidget);
    // Verify decision pill is TRAIN
    expect(find.text("TRAIN"), findsOneWidget);
    // Verify the explanation is shown
    expect(find.text("Welcome! Start your fitness journey with a moderate introductory full-body workout."), findsOneWidget);

    // Verify the CTA button
    final ctaButton = find.text("START RECOMMENDED WORKOUT");
    expect(ctaButton, findsOneWidget);

    // Tap CTA
    await tester.tap(ctaButton);
    await tester.pumpAndSettle();

    // Verify it navigates to active session screen showing INTRODUCTORY SPLIT workout name and session screen controls
    expect(find.byIcon(Icons.add_circle_outline), findsWidgets);
    expect(find.text("INTRODUCTORY SPLIT"), findsOneWidget);
  });
}

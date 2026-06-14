import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/core/monitoring/crash_triage.dart';
import 'package:workout/features/workout/providers/workout_providers.dart';
import 'package:workout/features/workout/domain/workout.dart';
import 'package:workout/features/workout/domain/exercise.dart';
import 'package:workout/features/workout/domain/workout_set.dart';
import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/features/workout/data/local_storage_workout_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Regression Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Cold Start Latency Benchmark', () async {
      final stopwatch = Stopwatch()..start();
      
      final repo = LocalStorageWorkoutRepository(prefs);
      await repo.getWorkouts();
      
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      // ignore: avoid_print
      print('Cold Start took ${ms}ms');
      expect(ms, lessThan(1800), reason: 'Cold start must be under 1.8s');
    });

    test('Session State Update Latency Benchmark', () async {
      final repo = LocalStorageWorkoutRepository(prefs);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          workoutRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final workout = Workout(
        id: 'w1',
        name: 'Upper Body A',
        exercises: [
          WorkoutExercise(
            exercise: const Exercise(id: 'e1', name: 'Bench Press'),
            sets: [
              const WorkoutSet(reps: 10, weight: 60, isCompleted: false),
            ],
          ),
        ],
      );

      // Warm up
      container.read(activeSessionProvider);

      final notifier = container.read(activeSessionProvider.notifier);
      await notifier.startSession(workout);

      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 50; i++) {
        notifier.updateSet(
          0,
          0,
          WorkoutSet(reps: 10 + i % 3, weight: 60.0 + i, isCompleted: i % 2 == 0),
        );
      }

      stopwatch.stop();
      final avgLatency = stopwatch.elapsedMilliseconds / 50.0;
      // ignore: avoid_print
      print('Average Session Update Latency: ${avgLatency}ms');
      expect(avgLatency, lessThan(50), reason: 'Session update latency must be under 50ms');
    });

    test('Dashboard Calculations/Render Benchmark', () async {
      final repo = LocalStorageWorkoutRepository(prefs);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          workoutRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final history = List.generate(50, (index) => WorkoutSession(
        id: 'session_$index',
        workout: Workout(
          id: 'w1',
          name: 'Bench Day',
          exercises: [
            WorkoutExercise(
              exercise: const Exercise(id: 'e1', name: 'Bench Press'),
              sets: [
                WorkoutSet(reps: 8, weight: 80.0 + index, isCompleted: true),
                WorkoutSet(reps: 8, weight: 80.0 + index, isCompleted: true),
              ],
            ),
          ],
        ),
        startTime: DateTime.now().subtract(Duration(days: 50 - index)),
        endTime: DateTime.now().subtract(Duration(days: 50 - index)).add(const Duration(minutes: 45)),
      ));

      final envelope = {
        'version': 1,
        'data': history.map((s) => s.toJson()).toList(),
      };
      await prefs.setString('sessions_v1', jsonEncode(envelope));

      final stopwatch = Stopwatch()..start();
      
      await container.read(workoutHistoryProvider.future);
      container.read(workoutStatsProvider);
      container.read(workoutStreakProvider);

      stopwatch.stop();
      final calculationMs = stopwatch.elapsedMilliseconds;
      // ignore: avoid_print
      print('Dashboard calculations took ${calculationMs}ms');
      expect(calculationMs, lessThan(200), reason: 'Dashboard computation must be under 200ms');
    });
  });
}

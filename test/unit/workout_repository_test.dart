import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/features/workout/data/local_storage_workout_repository.dart';
import 'package:workout/features/workout/domain/workout.dart';

void main() {
  group('LocalStorageWorkoutRepository', () {
    late SharedPreferences prefs;
    late LocalStorageWorkoutRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = LocalStorageWorkoutRepository(prefs);
    });

    test('getWorkouts returns empty list when no data', () async {
      final workouts = await repository.getWorkouts();
      expect(workouts, isEmpty);
    });

    test('createWorkout adds a workout and persists it', () async {
      const workout = Workout(id: '1', name: 'Test Workout', exercises: []);
      await repository.createWorkout(workout);
      
      final workouts = await repository.getWorkouts();
      expect(workouts, hasLength(1));
      expect(workouts.first.name, 'Test Workout');
    });

    test('recovers from corrupted JSON by returning empty list', () async {
      await prefs.setString('workouts_v1', 'invalid json{');
      final workouts = await repository.getWorkouts();
      expect(workouts, isEmpty);
    });

    test('recovers from invalid schema by returning empty list', () async {
      await prefs.setString('workouts_v1', jsonEncode({'wrong_key': []}));
      final workouts = await repository.getWorkouts();
      expect(workouts, isEmpty);
    });
  });
}

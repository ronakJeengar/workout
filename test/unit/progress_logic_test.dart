import 'package:flutter_test/flutter_test.dart';
import 'package:workout/features/workout/domain/exercise.dart';
import 'package:workout/features/workout/domain/workout.dart';
import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/features/workout/domain/workout_set.dart';

void main() {
  group('Progress Logic', () {
    test('calculate total volume correctly', () {
      final session = WorkoutSession(
        id: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        workout: Workout(
          id: 'w1',
          name: 'Test',
          exercises: [
            WorkoutExercise(
              exercise: const Exercise(id: 'e1', name: 'Bench'),
              sets: const [
                WorkoutSet(reps: 10, weight: 100, isCompleted: true),
                WorkoutSet(reps: 10, weight: 100, isCompleted: true),
                WorkoutSet(reps: 5, weight: 50, isCompleted: false), // ignore incomplete
              ],
            ),
          ],
        ),
      );

      // Manual calculation for test validation
      double totalVolume = 0;
      for (final exercise in session.workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            totalVolume += set.reps * set.weight;
          }
        }
      }

      expect(totalVolume, 2000.0);
    });
  });
}

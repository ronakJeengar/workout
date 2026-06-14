import 'program.dart';

class WeeklySplitGenerator {
  const WeeklySplitGenerator();

  Program generate({
    required String goal,
    required double recoveryScore,
    required List<String> availableWorkoutIds,
  }) {
    final workouts = <ScheduledWorkout>[];
    String name = 'Weekly Split';
    String description = 'Automated training program';

    final normalizedGoal = goal.toLowerCase();

    if (normalizedGoal.contains('strength')) {
      name = 'Power & Strength Split';
      description = 'Low rep, compound heavy strength training';
      if (availableWorkoutIds.length >= 3) {
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 1, order: 1)); // Mon
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[1], dayOfWeek: 3, order: 1)); // Wed
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[2], dayOfWeek: 5, order: 1)); // Fri
      } else if (availableWorkoutIds.isNotEmpty) {
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 1, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 3, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 5, order: 1));
      }
    } else if (normalizedGoal.contains('hypertrophy')) {
      name = 'Muscle Hypertrophy Split';
      description = 'Moderate rep volume hypertrophy split';
      if (availableWorkoutIds.length >= 4) {
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 1, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[1], dayOfWeek: 2, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[2], dayOfWeek: 4, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[3], dayOfWeek: 5, order: 1));
      } else if (availableWorkoutIds.length >= 2) {
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 1, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[1], dayOfWeek: 2, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 4, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[1], dayOfWeek: 5, order: 1));
      } else if (availableWorkoutIds.isNotEmpty) {
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 1, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 2, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 4, order: 1));
        workouts.add(ScheduledWorkout(workoutId: availableWorkoutIds[0], dayOfWeek: 5, order: 1));
      }
    } else {
      name = 'Fat Loss & Conditioning';
      description = 'High intensity conditioning circuit training';
      final days = recoveryScore < 0.5 ? [2, 4] : [1, 3, 5];
      int i = 0;
      for (final day in days) {
        if (availableWorkoutIds.isNotEmpty) {
          workouts.add(ScheduledWorkout(
            workoutId: availableWorkoutIds[i % availableWorkoutIds.length],
            dayOfWeek: day,
            order: 1,
          ));
          i++;
        }
      }
    }

    return Program(
      id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      workouts: workouts,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

import '../../workout/domain/workout_set.dart';

class ExerciseInsight {
  final String exerciseId;
  final String exerciseName;
  final double currentPR;
  final double estimated1RM;
  final List<WorkoutSet> lastPerformance;
  final double improvementPercent; // (current - previous) / previous

  const ExerciseInsight({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentPR,
    required this.estimated1RM,
    required this.lastPerformance,
    required this.improvementPercent,
  });
}

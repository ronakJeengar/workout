import '../../progress/domain/volume_point.dart';
import '../../workout/domain/workout_session.dart';
import '../../programs/domain/program.dart';
import '../../goals/domain/goal.dart';
import 'daily_recommendation.dart';

class DailyDecisionEngine {
  const DailyDecisionEngine();

  DailyRecommendation makeDecision({
    required List<WorkoutSession> history,
    required List<Program> programs,
    required List<Goal> goals,
    required double recoveryScore,
    required int streak,
    required List<VolumePoint> volumeTrends,
  }) {
    if (history.isEmpty) {
      return const DailyRecommendation(
        decision: TrainingDecision.train,
        recommendedWorkoutType: 'Introductory Split',
        intensityLevel: 'MEDIUM',
        primaryMuscleGroup: 'Full Body',
        confidenceScore: 90,
        explanation: 'Welcome! Start your fitness journey with a moderate introductory full-body workout.',
      );
    }

    if (recoveryScore < 0.5) {
      return DailyRecommendation(
        decision: TrainingDecision.rest,
        recommendedWorkoutType: 'Active Recovery Walk or Stretch',
        intensityLevel: 'LOW',
        primaryMuscleGroup: 'None',
        confidenceScore: 95,
        explanation: 'Your recovery score is low (${(recoveryScore * 100).toInt()}%). We suggest taking a rest day to allow muscle fibers to repair.',
      );
    }

    bool fatigueDetected = false;
    if (volumeTrends.length >= 3) {
      final last3 = volumeTrends.sublist(volumeTrends.length - 3);
      fatigueDetected = last3.every((p) => p.volume > 0.0);
    }

    if (fatigueDetected) {
      return const DailyRecommendation(
        decision: TrainingDecision.lightDay,
        recommendedWorkoutType: 'Active Mobility & Deload',
        intensityLevel: 'LOW',
        primaryMuscleGroup: 'Core & Mobility',
        confidenceScore: 85,
        explanation: 'Fatigue warning: You have completed high-volume sessions 3 days in a row. A light day is recommended to prevent overtraining.',
      );
    }

    if (streak > 0 && recoveryScore > 0.65) {
      String recommendedWorkout = 'Strength Training';
      String muscleGroup = 'Push / Pull';
      if (history.isNotEmpty) {
        recommendedWorkout = history.first.workout.name;
        if (history.first.workout.exercises.isNotEmpty) {
          muscleGroup = history.first.workout.exercises.first.exercise.muscleGroup ?? 'Upper Body';
        }
      }

      return DailyRecommendation(
        decision: TrainingDecision.train,
        recommendedWorkoutType: recommendedWorkout,
        intensityLevel: 'HIGH',
        primaryMuscleGroup: muscleGroup,
        confidenceScore: 90,
        explanation: 'Streak of $streak days is active and recovery is excellent (${(recoveryScore * 100).toInt()}%). Go ahead with a high-intensity session!',
      );
    }

    String recommendedWorkout = 'General Conditioning';
    String muscleGroup = 'Full Body';
    if (history.isNotEmpty) {
      recommendedWorkout = history.first.workout.name;
      if (history.first.workout.exercises.isNotEmpty) {
        muscleGroup = history.first.workout.exercises.first.exercise.muscleGroup ?? 'Full Body';
      }
    }

    return DailyRecommendation(
      decision: TrainingDecision.train,
      recommendedWorkoutType: recommendedWorkout,
      intensityLevel: 'MEDIUM',
      primaryMuscleGroup: muscleGroup,
      confidenceScore: 80,
      explanation: 'Recovery is stable. A medium-intensity session is recommended to stay consistent on your goals.',
    );
  }
}

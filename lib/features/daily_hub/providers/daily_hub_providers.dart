import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../coach/domain/coach_models.dart' as coach;
import '../../coach/providers/coach_providers.dart' as coach;
import '../../goals/providers/goal_providers.dart';
import '../../programs/providers/program_providers.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/domain/exercise.dart';
import '../../workout/domain/workout.dart';
import '../../workout/domain/workout_set.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/daily_decision_engine.dart';
import '../domain/daily_recommendation.dart';

/// Provider for the DailyDecisionEngine domain service.
final dailyDecisionEngineProvider = Provider<DailyDecisionEngine>((ref) {
  return const DailyDecisionEngine();
});

/// Exposes the recovery score / status.
final recoveryScoreProvider = Provider<AsyncValue<coach.RecoveryStatus>>((ref) {
  return ref.watch(coach.recoveryScoreProvider);
});

/// Exposes the daily recommendation from the decision engine.
final dailyDecisionProvider = Provider<AsyncValue<DailyRecommendation>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  final programsAsync = ref.watch(programListProvider);
  final goalsAsync = ref.watch(goalListProvider);
  final recoveryAsync = ref.watch(recoveryScoreProvider);
  final streakAsync = ref.watch(workoutStreakProvider);
  final volumeTrendsAsync = ref.watch(volumeTrendProvider);

  if (historyAsync.isLoading ||
      programsAsync.isLoading ||
      goalsAsync.isLoading ||
      recoveryAsync.isLoading ||
      streakAsync.isLoading ||
      volumeTrendsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (historyAsync.hasError) {
    return AsyncValue.error(historyAsync.error!, historyAsync.stackTrace!);
  }
  if (programsAsync.hasError) {
    return AsyncValue.error(programsAsync.error!, programsAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }
  if (recoveryAsync.hasError) {
    return AsyncValue.error(recoveryAsync.error!, recoveryAsync.stackTrace!);
  }
  if (streakAsync.hasError) {
    return AsyncValue.error(streakAsync.error!, streakAsync.stackTrace!);
  }
  if (volumeTrendsAsync.hasError) {
    return AsyncValue.error(volumeTrendsAsync.error!, volumeTrendsAsync.stackTrace!);
  }

  final history = historyAsync.value ?? [];
  final programs = programsAsync.value ?? [];
  final goals = goalsAsync.value ?? [];
  final recoveryScore = recoveryAsync.value?.score ?? 1.0;
  final streak = streakAsync.value ?? 0;
  final volumeTrends = volumeTrendsAsync.value ?? [];

  final engine = ref.read(dailyDecisionEngineProvider);
  final recommendation = engine.makeDecision(
    history: history,
    programs: programs,
    goals: goals,
    recoveryScore: recoveryScore,
    streak: streak,
    volumeTrends: volumeTrends,
  );

  return AsyncValue.data(recommendation);
});

/// Exposes the suggested workout for the daily recommendation.
final trainingSuggestionProvider = Provider<AsyncValue<Workout?>>((ref) {
  final decisionAsync = ref.watch(dailyDecisionProvider);
  final workoutsAsync = ref.watch(workoutListProvider);

  return decisionAsync.when(
    data: (recommendation) {
      return workoutsAsync.when(
        data: (workouts) {
          // Find if there is an existing workout matching the recommended workout name
          final matched = workouts.firstWhere(
            (w) => w.name.toLowerCase() == recommendation.recommendedWorkoutType.toLowerCase(),
            orElse: () {
              // Otherwise, look for a workout targeting the recommended primary muscle group
              return workouts.firstWhere(
                (w) => w.exercises.any((e) =>
                    e.exercise.muscleGroup?.toLowerCase() ==
                    recommendation.primaryMuscleGroup.toLowerCase()),
                orElse: () {
                  // Fallback: build a dynamic workout matching the recommendation
                  return Workout(
                    id: 'recommended_workout',
                    name: recommendation.recommendedWorkoutType,
                    exercises: [
                      WorkoutExercise(
                        exercise: Exercise(
                          id: 'custom_exercise',
                          name: recommendation.decision == TrainingDecision.rest
                              ? 'Active Stretch / Walk'
                              : 'General Exercise (${recommendation.primaryMuscleGroup})',
                          muscleGroup: recommendation.primaryMuscleGroup,
                        ),
                        sets: [
                          const WorkoutSet(reps: 10, weight: 10.0, isCompleted: false),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );
          return AsyncValue.data(matched);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

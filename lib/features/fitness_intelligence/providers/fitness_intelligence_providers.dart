import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_providers.dart';
import '../../workout/providers/workout_providers.dart';
import '../../goals/providers/goal_providers.dart';
import '../../daily_hub/providers/daily_hub_providers.dart' as daily_hub;
import '../../progress/providers/progress_provider.dart';
import '../body_goal_engine/body_goal_engine.dart';
import '../progression/progressive_overload_engine.dart';
import '../warmup/warmup_generator.dart';
import '../nutrition/nutrition_engine.dart';
import '../exercise_execution/exercise_execution_guide.dart';

/// Provider for the BodyGoalEngine domain service.
final bodyGoalEngineProvider = Provider<BodyGoalEngine>((ref) {
  return const BodyGoalEngine();
});

/// Provider for the ProgressiveOverloadEngine domain service.
final progressiveOverloadEngineProvider = Provider<ProgressiveOverloadEngine>((ref) {
  return const ProgressiveOverloadEngine();
});

/// Provider for Body Goal Evaluation.
final bodyGoalProvider = Provider<AsyncValue<BodyGoalRecommendation>>((ref) {
  final profile = ref.watch(profileProvider);
  final historyAsync = ref.watch(workoutHistoryProvider);
  final goalsAsync = ref.watch(goalListProvider);
  final recoveryAsync = ref.watch(daily_hub.recoveryScoreProvider);
  final progressOverviewAsync = ref.watch(progressOverviewProvider);

  if (historyAsync.isLoading ||
      goalsAsync.isLoading ||
      recoveryAsync.isLoading ||
      progressOverviewAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (historyAsync.hasError) {
    return AsyncValue.error(historyAsync.error!, historyAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }
  if (recoveryAsync.hasError) {
    return AsyncValue.error(recoveryAsync.error!, recoveryAsync.stackTrace!);
  }
  if (progressOverviewAsync.hasError) {
    return AsyncValue.error(progressOverviewAsync.error!, progressOverviewAsync.stackTrace!);
  }

  final history = historyAsync.value ?? [];
  final goals = goalsAsync.value ?? [];
  final recoveryScore = recoveryAsync.value?.score ?? 1.0;
  final weeklyVolume = progressOverviewAsync.value?.weeklyVolume ?? 0.0;

  final engine = ref.read(bodyGoalEngineProvider);
  final recommendation = engine.evaluateGoal(
    profile: profile,
    history: history,
    goals: goals,
    weeklyVolume: weeklyVolume,
    recoveryScore: recoveryScore,
  );

  return AsyncValue.data(recommendation);
});

/// Provider for Nutrition Plan.
final nutritionProvider = Provider<AsyncValue<NutritionPlan>>((ref) {
  final profile = ref.watch(profileProvider);
  final bodyGoalAsync = ref.watch(bodyGoalProvider);

  return bodyGoalAsync.when(
    data: (recommendation) {
      const engine = NutritionEngine();
      final plan = engine.generatePlan(
        profile: profile,
        mode: recommendation.mode,
      );
      return AsyncValue.data(plan);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

/// Family provider for warm-up sets, taking a muscle group and work weight.
final warmupProvider = Provider.family<WarmupPlan, ({String muscleGroup, double workWeight})>((ref, arg) {
  return WarmupGenerator.generate(arg.muscleGroup, arg.workWeight);
});

/// Family provider for progressive overload recommendation.
final progressionProvider = Provider.family<AsyncValue<ProgressiveOverloadRecommendation>, String>((ref, exerciseId) {
  final historyAsync = ref.watch(workoutHistoryProvider);

  return historyAsync.when(
    data: (history) {
      final engine = ref.read(progressiveOverloadEngineProvider);
      final recommendation = engine.evaluateProgression(
        exerciseId: exerciseId,
        history: history,
      );
      return AsyncValue.data(recommendation);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

/// Family provider for exercise execution instructions.
final executionGuideProvider = Provider.family<ExecutionInstructions, String>((ref, exerciseName) {
  return ExerciseExecutionGuide.getGuide(exerciseName);
});

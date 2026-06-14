import 'package:flutter_test/flutter_test.dart';
import 'package:workout/features/fitness_intelligence/body_goal_engine/body_goal_engine.dart';
import 'package:workout/features/fitness_intelligence/progression/progressive_overload_engine.dart';
import 'package:workout/features/fitness_intelligence/warmup/warmup_generator.dart';
import 'package:workout/features/fitness_intelligence/nutrition/nutrition_engine.dart';
import 'package:workout/features/fitness_intelligence/exercise_execution/exercise_execution_guide.dart';
import 'package:workout/features/profile/domain/user_profile.dart';
import 'package:workout/features/workout/domain/workout.dart';
import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/features/workout/domain/workout_set.dart';
import 'package:workout/features/workout/domain/exercise.dart';

void main() {
  group('BodyGoalEngine Tests', () {
    const engine = BodyGoalEngine();
    final profile = UserProfile(
      name: 'Tester',
      heightCm: 180,
      weightKg: 80,
      trainingAgeYears: 2,
      activityLevel: ActivityLevel.active,
      updatedAt: DateTime.now(),
    );

    test('Evaluate generic fitness mode calorie/protein output', () {
      final rec = engine.evaluateGoal(
        profile: profile,
        history: [],
        goals: [],
        weeklyVolume: 10000.0,
        recoveryScore: 0.8,
      );

      expect(rec.mode, BodyGoalMode.generalFitness);
      expect(rec.dailyCalories, closeTo(profile.estimatedTDEE, 0.01));
      expect(rec.proteinTargetGrams, 80 * 1.6);
      expect(rec.intensityRecommendation, 'HIGH (Ready to push heavy loads)');
      expect(rec.trainingSplitSuggestion, 'Upper / Lower (4x/week)');
    });
  });

  group('ProgressiveOverloadEngine Tests', () {
    const engine = ProgressiveOverloadEngine();

    test('Returns BASELINE action for empty/insufficient history', () {
      final rec = engine.evaluateProgression(exerciseId: 'squat', history: []);
      expect(rec.action, 'BASELINE');
    });
  });

  group('WarmupGenerator Tests', () {
    test('Generate warmup sets and dynamic warmups for chest', () {
      final plan = WarmupGenerator.generate('chest', 100.0);
      expect(plan.sets.length, 3);
      expect(plan.sets[0].percent, 20.0);
      expect(plan.sets[0].reps, 10);
      expect(plan.mobilitySuggestions.any((m) => m.contains('dislocates')), true);
    });
  });

  group('NutritionEngine Tests', () {
    const engine = NutritionEngine();
    final profile = UserProfile(
      name: 'Tester',
      heightCm: 180,
      weightKg: 80,
      trainingAgeYears: 2,
      activityLevel: ActivityLevel.active,
      updatedAt: DateTime.now(),
    );

    test('Macronutrient splits add up to correct calories', () {
      final plan = engine.generatePlan(profile: profile, mode: BodyGoalMode.muscleGain);
      final computedCalories = (plan.proteinGrams * 4.0) + (plan.carbsGrams * 4.0) + (plan.fatsGrams * 9.0);
      expect(computedCalories, closeTo(plan.calories, 0.1));
    });
  });

  group('ExerciseExecutionGuide Tests', () {
    test('Retrieve Squat form instructions', () {
      final guide = ExerciseExecutionGuide.getGuide('Barbell Squat');
      expect(guide.steps.any((s) => s.contains('Stand with feet')), true);
      expect(guide.commonMistakes.any((m) => m.contains('valgus')), true);
    });
  });
}

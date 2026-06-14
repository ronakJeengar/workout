import 'package:workout/features/profile/domain/user_profile.dart';
import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/features/goals/domain/goal.dart';

enum BodyGoalMode {
  muscleGain,
  fatLoss,
  weightGain,
  strength,
  generalFitness,
}

class BodyGoalRecommendation {
  final BodyGoalMode mode;
  final double dailyCalories;
  final double proteinTargetGrams;
  final String intensityRecommendation;
  final String trainingSplitSuggestion;
  final String explanation;

  const BodyGoalRecommendation({
    required this.mode,
    required this.dailyCalories,
    required this.proteinTargetGrams,
    required this.intensityRecommendation,
    required this.trainingSplitSuggestion,
    required this.explanation,
  });
}

class BodyGoalEngine {
  const BodyGoalEngine();

  BodyGoalRecommendation evaluateGoal({
    required UserProfile profile,
    required List<WorkoutSession> history,
    required List<Goal> goals,
    required double weeklyVolume,
    required double recoveryScore,
  }) {
    // Determine the user's current goal mode based on goals list first
    BodyGoalMode mode = BodyGoalMode.generalFitness;
    if (goals.isNotEmpty) {
      final title = goals.first.title.toLowerCase();
      if (title.contains('gain') && (title.contains('muscle') || title.contains('mass'))) {
        mode = BodyGoalMode.muscleGain;
      } else if (title.contains('loss') || title.contains('lose') || title.contains('fat') || title.contains('cut')) {
        mode = BodyGoalMode.fatLoss;
      } else if (title.contains('gain') && title.contains('weight')) {
        mode = BodyGoalMode.weightGain;
      } else if (title.contains('strength') || title.contains('lift') || title.contains('pr')) {
        mode = BodyGoalMode.strength;
      }
    }

    final tdee = profile.estimatedTDEE;
    double calories = tdee;
    double protein = profile.weightKg * 1.6;

    String explanation = '';
    switch (mode) {
      case BodyGoalMode.muscleGain:
        calories = tdee + 300;
        protein = profile.weightKg * 2.0;
        explanation = 'Caloric surplus of +300kcal and high protein (2.0g/kg) to maximize muscle protein synthesis.';
        break;
      case BodyGoalMode.fatLoss:
        calories = tdee - 500;
        protein = profile.weightKg * 2.2;
        explanation = 'Caloric deficit of -500kcal and elevated protein (2.2g/kg) to preserve lean muscle tissue.';
        break;
      case BodyGoalMode.weightGain:
        calories = tdee + 500;
        protein = profile.weightKg * 1.6;
        explanation = 'Substantial caloric surplus of +500kcal to support weight gain.';
        break;
      case BodyGoalMode.strength:
        calories = tdee + 150;
        protein = profile.weightKg * 2.0;
        explanation = 'Slight surplus of +150kcal and high protein (2.0g/kg) to support recovery and neurological strength adaptations.';
        break;
      case BodyGoalMode.generalFitness:
        calories = tdee;
        protein = profile.weightKg * 1.6;
        explanation = 'Maintenance calories and moderate protein to support general health and aerobic conditioning.';
        break;
    }

    String intensity = 'MEDIUM';
    if (recoveryScore < 0.50) {
      intensity = 'LOW (Focus on active recovery)';
    } else if (recoveryScore > 0.75) {
      intensity = 'HIGH (Ready to push heavy loads)';
    } else {
      intensity = 'MEDIUM (Balanced training volume)';
    }

    String split = 'Full Body (3x/week)';
    if (profile.trainingAgeYears < 1) {
      split = 'Full Body (3x/week)';
    } else if (profile.trainingAgeYears < 3) {
      split = 'Upper / Lower (4x/week)';
    } else {
      split = 'Push / Pull / Legs (5-6x/week)';
    }

    return BodyGoalRecommendation(
      mode: mode,
      dailyCalories: calories,
      proteinTargetGrams: protein,
      intensityRecommendation: intensity,
      trainingSplitSuggestion: split,
      explanation: explanation,
    );
  }
}

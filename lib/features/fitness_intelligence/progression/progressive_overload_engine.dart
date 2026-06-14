import 'package:workout/features/workout/domain/workout_session.dart';

class ProgressiveOverloadRecommendation {
  final String action; // WEIGHT_INCREASE, REP_INCREASE, DELOAD, VARIATION_SUGGESTION, BASELINE
  final double weightChangePercent;
  final int repChange;
  final String explanation;

  const ProgressiveOverloadRecommendation({
    required this.action,
    required this.weightChangePercent,
    required this.repChange,
    required this.explanation,
  });
}

class ProgressiveOverloadEngine {
  const ProgressiveOverloadEngine();

  ProgressiveOverloadRecommendation evaluateProgression({
    required String exerciseId,
    required List<WorkoutSession> history,
  }) {
    // Filter history containing this exercise
    final relevantSessions = history.where((s) => s.workout.exercises.any((e) => e.exercise.id == exerciseId)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)); // Chronological order

    if (relevantSessions.length < 2) {
      return const ProgressiveOverloadRecommendation(
        action: 'BASELINE',
        weightChangePercent: 0.0,
        repChange: 0,
        explanation: 'Establish your baseline. Track this exercise for at least 2 sessions to compute overload suggestions.',
      );
    }

    // Sort to trace PRs chronologically
    double historicMaxWeight = 0.0;
    final prSessions = <String>{};

    for (final session in relevantSessions) {
      double sessionMaxWeight = 0.0;
      for (final exercise in session.workout.exercises) {
        if (exercise.exercise.id == exerciseId) {
          for (final set in exercise.sets) {
            if (set.isCompleted && set.weight > sessionMaxWeight) {
              sessionMaxWeight = set.weight;
            }
          }
        }
      }
      if (sessionMaxWeight > historicMaxWeight) {
        prSessions.add(session.id);
        historicMaxWeight = sessionMaxWeight;
      }
    }

    // Check last session and second-to-last session
    final lastSession = relevantSessions.last;
    final lastExercise = lastSession.workout.exercises.firstWhere((e) => e.exercise.id == exerciseId);
    
    // Check stagnation: no PR in the last 3 sessions containing this exercise
    bool isStagnated = false;
    if (relevantSessions.length >= 3) {
      final last3 = relevantSessions.sublist(relevantSessions.length - 3);
      isStagnated = last3.every((s) => !prSessions.contains(s.id));
    }

    if (isStagnated) {
      return const ProgressiveOverloadRecommendation(
        action: 'VARIATION_SUGGESTION',
        weightChangePercent: 0.0,
        repChange: 0,
        explanation: 'Stagnation warning: No personal record in the last 3 sessions. Consider changing rep ranges or swapping with a variation (e.g. Incline Bench to Dumbbell Flyes) to break the plateau.',
      );
    }

    // Check if last session was a PR
    final isLastPR = prSessions.contains(lastSession.id);
    if (isLastPR) {
      return const ProgressiveOverloadRecommendation(
        action: 'WEIGHT_INCREASE',
        weightChangePercent: 2.5,
        repChange: 0,
        explanation: 'PR detected! Increase working weight by 2.5% in your next session to maintain overload.',
      );
    }

    // Check if user completed all reps in their sets
    bool allSetsCompleted = lastExercise.sets.isNotEmpty && lastExercise.sets.every((s) => s.isCompleted);
    if (allSetsCompleted) {
      return const ProgressiveOverloadRecommendation(
        action: 'REP_INCREASE',
        weightChangePercent: 0.0,
        repChange: 1,
        explanation: 'Working weight is stable. Add 1 rep to your sets to accumulate training volume before increasing weight.',
      );
    }

    // Fallback deload if performance decreased (fatigue)
    return const ProgressiveOverloadRecommendation(
      action: 'DELOAD',
      weightChangePercent: -10.0,
      repChange: 0,
      explanation: 'Fatigue/regression warning: Reps or weight dropped in the last session. Reduce volume/load by 10% next session to allow recovery.',
    );
  }
}

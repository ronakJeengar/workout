import 'package:workout/features/workout/domain/workout_session.dart';
import 'package:workout/features/progress/domain/progress_overview.dart';
import 'package:workout/features/goals/domain/goal.dart';
import 'package:workout/features/settings/domain/app_settings.dart';
import '../domain/coach_recommendation.dart';
import '../domain/fatigue_model.dart';

class CoachRuleEngine {
  const CoachRuleEngine();

  FatigueModel calculateFatigue({
    required List<WorkoutSession> history,
    required ProgressOverview overview,
  }) {
    if (history.isEmpty) {
      return const FatigueModel(
        fatigueScore: 0.0,
        recoveryState: FatigueState.low,
        contributingFactors: ['No training history logged yet.'],
      );
    }

    double score = 0.0;
    final now = DateTime.now();
    final factors = <String>[];

    // 1. Last 7 Days Volume vs Avg 30 Days Volume
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    double vol7Days = 0.0;
    double vol30Days = 0.0;
    int count7Days = 0;

    for (final s in history) {
      double sVol = 0.0;
      for (final ex in s.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) sVol += set.reps * set.weight;
        }
      }

      if (s.startTime.isAfter(sevenDaysAgo)) {
        vol7Days += sVol;
        count7Days++;
      }
      if (s.startTime.isAfter(thirtyDaysAgo)) {
        vol30Days += sVol;
      }
    }

    final avgWeeklyVol = vol30Days / 4.0;
    if (avgWeeklyVol > 0.0) {
      final ratio = vol7Days / avgWeeklyVol;
      if (ratio > 1.25) {
        score += 0.35;
        factors.add('Recent weekly volume is 25%+ higher than 30-day average.');
      } else if (ratio > 1.0) {
        score += 0.15;
        factors.add('Slightly elevated weekly training volume.');
      }
    }

    // 2. Training frequency load
    if (count7Days >= 5) {
      score += 0.3;
      factors.add('High weekly frequency ($count7Days workouts in last 7 days).');
    } else if (count7Days >= 3) {
      score += 0.1;
    }

    // 3. Rest gaps (hours since last workout)
    final lastSession = history.first;
    final hoursSince = now.difference(lastSession.startTime).inHours;
    if (hoursSince < 24) {
      score += 0.3;
      factors.add('Less than 24 hours of rest since your last workout.');
    } else if (hoursSince < 48) {
      score += 0.1;
    } else if (hoursSince > 96) {
      score -= 0.2;
      factors.add('Extended rest period (4+ days) has fully repleted energy stores.');
    }

    // 4. Performance decline
    if (history.length >= 2) {
      final s1 = history[0];
      final s2 = history[1];
      double v1 = 0.0;
      double v2 = 0.0;
      for (final ex in s1.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) v1 += set.reps * set.weight;
        }
      }
      for (final ex in s2.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) v2 += set.reps * set.weight;
        }
      }
      if (v1 < v2 * 0.9) {
        score += 0.15;
        factors.add('Recent session volume dropped by 10%+.');
      }
    }

    final finalScore = score.clamp(0.0, 1.0);
    FatigueState state = FatigueState.low;
    if (finalScore >= 0.8) {
      state = FatigueState.overtrained;
    } else if (finalScore >= 0.6) {
      state = FatigueState.high;
    } else if (finalScore >= 0.3) {
      state = FatigueState.moderate;
    }

    if (factors.isEmpty) {
      factors.add('Ideal training volume and rest gaps.');
    }

    return FatigueModel(
      fatigueScore: finalScore,
      recoveryState: state,
      contributingFactors: factors,
    );
  }

  List<CoachRecommendation> generateRecommendations({
    required List<WorkoutSession> history,
    required ProgressOverview overview,
    required FatigueModel fatigue,
    required List<Goal> goals,
  }) {
    final list = <CoachRecommendation>[];
    final now = DateTime.now();

    if (history.isEmpty) {
      list.add(CoachRecommendation(
        title: 'WELCOME TO COACH',
        message: 'Complete your first workout session to enable rule-based fatigue and progressive overload insights.',
        type: CoachRecommendationType.insight,
        intensity: RecommendationIntensity.low,
        timestamp: now,
      ));
      return list;
    }

    // Rule A — Overtraining
    if (fatigue.fatigueScore > 0.8) {
      list.add(CoachRecommendation(
        title: 'CRITICAL OVERTRAINING',
        message: 'Your fatigue index is critical (${(fatigue.fatigueScore * 100).toInt()}%). We strongly recommend a deload session or 2 full rest days to prevent injury.',
        type: CoachRecommendationType.warning,
        intensity: RecommendationIntensity.low,
        timestamp: now,
      ));
    }

    // Rule B — No Progress (14 days plateaus)
    bool isStagnated = checkNoPR14Days(history);
    if (isStagnated) {
      list.add(CoachRecommendation(
        title: 'STAGNATION DETECTED',
        message: 'No personal record or strength increases in the last 14 days. We suggest changing your rep ranges or swapping with exercise variations.',
        type: CoachRecommendationType.suggestion,
        intensity: RecommendationIntensity.medium,
        timestamp: now,
      ));
    }

    // Rule C — Good Progress
    bool hadRecentPR = false;
    if (history.isNotEmpty) {
      hadRecentPR = !isStagnated;
    }
    if (hadRecentPR && fatigue.fatigueScore < 0.6) {
      list.add(CoachRecommendation(
        title: 'EXCELLENT PROGRESSION',
        message: 'Your strength trends are rising while fatigue is well managed. Try increasing working weights by 2.5% to 5% next session!',
        type: CoachRecommendationType.insight,
        intensity: RecommendationIntensity.high,
        timestamp: now,
      ));
    }

    // Rule D — Low Consistency
    final workoutsPerWeek = overview.workoutsThisWeek;
    if (workoutsPerWeek < 3) {
      list.add(CoachRecommendation(
        title: 'BUILD CONSISTENCY',
        message: 'You logged $workoutsPerWeek workouts recently. Consistency is key; try switching to an easier or shorter program to build a steady habit.',
        type: CoachRecommendationType.suggestion,
        intensity: RecommendationIntensity.medium,
        timestamp: now,
      ));
    }

    // Rule E — High Consistency + Low Fatigue
    if (workoutsPerWeek >= 3 && fatigue.fatigueScore < 0.4) {
      list.add(CoachRecommendation(
        title: 'PUSH YOUR LIMITS',
        message: 'Your training consistency is high and fatigue is low. Squeeze extra effort on your final sets, pushing closer to failure (RPE 9-10).',
        type: CoachRecommendationType.insight,
        intensity: RecommendationIntensity.high,
        timestamp: now,
      ));
    }

    // Default achievement card if streak is high
    if (overview.currentStreak >= 5) {
      list.add(CoachRecommendation(
        title: 'CONSISTENCY FIRE',
        message: 'Streak of ${overview.currentStreak} days active! You are building exceptional mental and physical momentum.',
        type: CoachRecommendationType.achievement,
        intensity: RecommendationIntensity.medium,
        timestamp: now,
      ));
    }

    return list;
  }

  bool checkNoPR14Days(List<WorkoutSession> history) {
    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final sessionsInLast14 = history.where((s) => s.startTime.isAfter(fourteenDaysAgo)).toList();

    if (sessionsInLast14.isEmpty) return false;

    final previousHistory = history.where((s) => s.startTime.isBefore(fourteenDaysAgo)).toList();
    final exerciseBests = <String, double>{};
    for (final s in previousHistory) {
      for (final ex in s.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) {
            final currentBest = exerciseBests[ex.exercise.id] ?? 0.0;
            if (set.weight > currentBest) {
              exerciseBests[ex.exercise.id] = set.weight;
            }
          }
        }
      }
    }

    bool hadPR = false;
    for (final s in sessionsInLast14) {
      for (final ex in s.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) {
            final best = exerciseBests[ex.exercise.id] ?? 0.0;
            if (set.weight > best) {
              hadPR = true;
              exerciseBests[ex.exercise.id] = set.weight;
            }
          }
        }
      }
    }

    return !hadPR;
  }
}

class CoachEngine {
  final CoachRuleEngine ruleEngine = const CoachRuleEngine();

  const CoachEngine();

  List<CoachRecommendation> evaluate({
    required List<WorkoutSession> history,
    required ProgressOverview overview,
    required List<Goal> goals,
    required AppSettings settings,
    required FatigueModel fatigue,
  }) {
    return ruleEngine.generateRecommendations(
      history: history,
      overview: overview,
      fatigue: fatigue,
      goals: goals,
    );
  }
}

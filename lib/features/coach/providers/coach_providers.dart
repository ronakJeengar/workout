import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/coach_models.dart';
import '../domain/adaptive_training_service.dart';

final coachProvider = Provider<AsyncValue<List<CoachInsight>>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  final overviewAsync = ref.watch(progressOverviewProvider);

  return historyAsync.when(
    data: (history) => overviewAsync.when(
      data: (overview) {
        final List<CoachInsight> insights = [];

        // 1. Frequency Check
        if (overview.workoutsThisWeek < 2) {
          insights.add(CoachInsight(
            title: 'MOMENTUM ALERT',
            message: 'You\'ve only logged ${overview.workoutsThisWeek} workouts this week. Try a short session to keep the streak!',
            type: InsightType.caution,
          ));
        }

        // 2. Volume Progression
        if (overview.weeklyVolume > 0) {
          insights.add(const CoachInsight(
            title: 'PROGRESSIVE OVERLOAD',
            message: 'Your total volume is up. Excellent work on pushing your limits!',
            type: InsightType.improvement,
          ));
        }

        // 3. Deload Suggestion (Simplified logic: if streak > 14 and last session was high volume)
        if (overview.currentStreak > 14) {
          insights.add(const CoachInsight(
            title: 'RECOVERY FOCUS',
            message: 'You\'ve trained for 14+ days straight. Consider a deload session or a rest day.',
            type: InsightType.recommendation,
          ));
        }

        if (insights.isEmpty) {
          insights.add(const CoachInsight(
            title: 'READY TO TRAIN',
            message: 'All metrics look good. Select a workout and get after it!',
            type: InsightType.recommendation,
          ));
        }

        return AsyncValue.data(insights);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final recoveryScoreProvider = Provider<AsyncValue<RecoveryStatus>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  
  return historyAsync.whenData((history) {
    if (history.isEmpty) {
      return const RecoveryStatus(score: 1.0, label: 'READY', description: 'Begin your journey today!');
    }

    final lastSession = history.first;
    final hoursSince = DateTime.now().difference(lastSession.startTime).inHours;

    if (hoursSince < 24) {
      return const RecoveryStatus(score: 0.3, label: 'RECOVER', description: 'Your body is rebuilding. High intensity not advised.');
    } else if (hoursSince < 48) {
      return const RecoveryStatus(score: 0.7, label: 'MODERATE', description: 'Good recovery. Listen to your joints.');
    } else {
      return const RecoveryStatus(score: 1.0, label: 'READY', description: 'Fully recovered and primed for peak performance.');
    }
  });
});

final adaptiveTrainingServiceProvider = Provider<AdaptiveTrainingService>((ref) {
  return const AdaptiveTrainingService();
});

final adaptiveTrainingOutputProvider = Provider<AsyncValue<AdaptationOutput>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  final streakAsync = ref.watch(workoutStreakProvider);
  final recoveryAsync = ref.watch(recoveryScoreProvider);

  return historyAsync.when(
    data: (history) => streakAsync.when(
      data: (streak) => recoveryAsync.when(
        data: (recovery) {
          double prFrequency = 0.2;
          if (history.isNotEmpty) {
            final prs = history.where((s) => s.workout.exercises.any((e) => e.sets.any((set) => set.isCompleted && set.weight > 60))).length;
            prFrequency = prs / history.length;
          }
          
          int missedSessions = 0;
          if (history.isNotEmpty) {
            DateTime? prev;
            for (final session in history.take(10)) {
              if (prev != null) {
                final diff = prev.difference(session.startTime).inDays;
                if (diff > 4) missedSessions++;
              }
              prev = session.startTime;
            }
          }

          final service = ref.read(adaptiveTrainingServiceProvider);
          final output = service.analyze(
            history: history,
            streak: streak,
            prFrequency: prFrequency,
            missedSessions: missedSessions,
            recoveryScore: recovery.score,
          );
          return AsyncValue.data(output);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

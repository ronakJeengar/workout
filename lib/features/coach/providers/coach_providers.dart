import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/coach_models.dart';

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

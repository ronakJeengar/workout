import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/progress_overview.dart';
import '../domain/exercise_insight.dart';
import '../domain/volume_point.dart';

/// Comprehensive overview provider
final progressOverviewProvider = Provider<AsyncValue<ProgressOverview>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);

  return historyAsync.whenData((history) {
    double totalVolume = 0;
    Duration totalDuration = Duration.zero;
    
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    double weeklyVolume = 0;
    double monthlyVolume = 0;
    int workoutsThisWeek = 0;

    for (final session in history) {
      double sessionVolume = 0;
      for (final exercise in session.workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            sessionVolume += set.reps * set.weight;
          }
        }
      }
      
      totalVolume += sessionVolume;
      if (session.endTime != null) {
        totalDuration += session.endTime!.difference(session.startTime);
      }

      if (session.startTime.isAfter(sevenDaysAgo)) {
        weeklyVolume += sessionVolume;
        workoutsThisWeek++;
      }
      if (session.startTime.isAfter(thirtyDaysAgo)) {
        monthlyVolume += sessionVolume;
      }
    }

    // Streak logic
    int currentStreak = 0;
    int longestStreak = 0;
    final sessionDates = history
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sessionDates.isNotEmpty) {
      DateTime today = DateTime(now.year, now.month, now.day);
      if (!sessionDates.first.isBefore(today.subtract(const Duration(days: 1)))) {
        int tempStreak = 0;
        for (int i = 0; i < sessionDates.length; i++) {
          final expectedDate = sessionDates.first.subtract(Duration(days: i));
          if (sessionDates.any((d) => d.year == expectedDate.year && d.month == expectedDate.month && d.day == expectedDate.day)) {
            tempStreak++;
          } else {
            break;
          }
        }
        currentStreak = tempStreak;
      }

      int tempLongest = 0;
      int currentTemp = 0;
      DateTime? prevDate;
      final sortedDates = List<DateTime>.from(sessionDates)..sort();
      for (final date in sortedDates) {
        if (prevDate == null || date.difference(prevDate).inDays == 1) {
          currentTemp++;
        } else if (date.difference(prevDate).inDays > 1) {
          currentTemp = 1;
        }
        if (currentTemp > tempLongest) tempLongest = currentTemp;
        prevDate = date;
      }
      longestStreak = tempLongest;
    }

    return ProgressOverview(
      totalSessions: history.length,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyVolume: weeklyVolume,
      monthlyVolume: monthlyVolume,
      workoutsThisWeek: workoutsThisWeek,
    );
  });
});

/// Exercise-specific insights
final exerciseInsightProvider = Provider.family<AsyncValue<ExerciseInsight?>, String>((ref, exerciseId) {
  final historyAsync = ref.watch(workoutHistoryProvider);

  return historyAsync.whenData((history) {
    double currentPR = 0;
    double estimated1RM = 0;
    final performances = <double>[]; // List of best weights per session

    // Filter history for sessions containing this exercise
    final relevantSessions = history.where((s) => s.workout.exercises.any((e) => e.exercise.id == exerciseId)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)); // Chronological

    for (final session in relevantSessions) {
      double sessionBestWeight = 0;
      for (final exercise in session.workout.exercises) {
        if (exercise.exercise.id == exerciseId) {
          for (final set in exercise.sets) {
            if (set.isCompleted) {
              if (set.weight > sessionBestWeight) {
                sessionBestWeight = set.weight;
              }
              double oneRM = set.weight * (1 + set.reps / 30.0);
              if (oneRM > estimated1RM) estimated1RM = oneRM;
            }
          }
        }
      }

      if (sessionBestWeight > 0) {
        performances.add(sessionBestWeight);
        if (sessionBestWeight > currentPR) {
          currentPR = sessionBestWeight;
        }
      }
    }

    if (performances.isEmpty) return null;

    final latestSession = relevantSessions.last;
    final name = latestSession.workout.exercises.firstWhere((e) => e.exercise.id == exerciseId).exercise.name;

    double improvement = 0;
    if (performances.length >= 2) {
      double latest = performances.last;
      double previous = performances[performances.length - 2];
      improvement = previous > 0 ? (latest - previous) / previous : 0;
    }

    return ExerciseInsight(
      exerciseId: exerciseId,
      exerciseName: name,
      currentPR: currentPR,
      estimated1RM: estimated1RM,
      lastPerformance: latestSession.workout.exercises.firstWhere((e) => e.exercise.id == exerciseId).sets,
      improvementPercent: improvement,
    );
  });
});

/// Volume trend for the last 30 days
final volumeTrendProvider = Provider<AsyncValue<List<VolumePoint>>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);

  return historyAsync.whenData((history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final points = <VolumePoint>[];
    
    final volumeByDate = <DateTime, double>{};
    for (final session in history) {
      final sDay = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      double sessionVolume = 0;
      for (final exercise in session.workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            sessionVolume += set.reps * set.weight;
          }
        }
      }
      volumeByDate[sDay] = (volumeByDate[sDay] ?? 0) + sessionVolume;
    }

    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayVolume = volumeByDate[day] ?? 0.0;
      points.add(VolumePoint(date: day, volume: dayVolume));
    }
    return points;
  });
});

/// Consistency score (completed days / available days in last 30 days)
final consistencyProvider = Provider<AsyncValue<double>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);

  return historyAsync.whenData((history) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final activeDays = history
        .where((s) => s.startTime.isAfter(thirtyDaysAgo))
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .length;
        
    return activeDays / 30.0;
  });
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../programs/providers/program_providers.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/providers/workout_providers.dart';
import '../data/goal_repository.dart';
import '../domain/goal.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  throw UnimplementedError('goalRepositoryProvider must be overridden');
});

class GoalListNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    final repo = ref.read(goalRepositoryProvider);
    final goals = await repo.getGoals();
    return _autoUpdateGoals(goals);
  }

  Future<List<Goal>> _autoUpdateGoals(List<Goal> goals) async {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final overviewAsync = ref.watch(progressOverviewProvider);

    if (historyAsync.isLoading || overviewAsync.isLoading) return goals;
    
    final history = historyAsync.value ?? [];
    final overview = overviewAsync.value;
    if (overview == null) return goals;
    
    bool changed = false;
    final updatedGoals = goals.map((goal) {
      double newProgress = goal.progress;
      
      switch (goal.type) {
        case GoalType.workoutsPerWeek:
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          newProgress = history.where((s) => s.startTime.isAfter(startOfWeek)).length.toDouble();
          break;
        case GoalType.volumeTarget:
          newProgress = overview.totalVolume;
          break;
        case GoalType.streakTarget:
          newProgress = overview.currentStreak.toDouble();
          break;
        case GoalType.sessionTarget:
          newProgress = overview.totalSessions.toDouble();
          break;
      }

      if (newProgress != goal.progress) {
        changed = true;
        DateTime? completedAt = goal.completedAt;
        if (newProgress >= goal.target && completedAt == null) {
          completedAt = DateTime.now();
        }
        return goal.copyWith(progress: newProgress, completedAt: completedAt);
      }
      return goal;
    }).toList();

    if (changed) {
      final repo = ref.read(goalRepositoryProvider);
      for (final g in updatedGoals) {
        await repo.saveGoal(g);
      }
    }
    return updatedGoals;
  }

  Future<void> addGoal(String title, GoalType type, double target) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(goalRepositoryProvider);
      final goal = Goal(
        id: DateTime.now().toIso8601String(),
        title: title,
        type: type,
        target: target,
        createdAt: DateTime.now(),
      );
      await repo.saveGoal(goal);
      return build();
    });
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(goalRepositoryProvider);
      await repo.deleteGoal(id);
      return build();
    });
  }
}

final goalListProvider = AsyncNotifierProvider<GoalListNotifier, List<Goal>>(() {
  return GoalListNotifier();
});

class AchievementNotifier extends AsyncNotifier<List<Achievement>> {
  @override
  Future<List<Achievement>> build() async {
    final repo = ref.read(goalRepositoryProvider);
    final achievements = await repo.getAchievements();
    return _checkAchievements(achievements);
  }

  Future<List<Achievement>> _checkAchievements(List<Achievement> achievements) async {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final overviewAsync = ref.watch(progressOverviewProvider);
    final programsAsync = ref.watch(programListProvider);
    final consistencyAsync = ref.watch(consistencyProvider);

    if (historyAsync.isLoading || overviewAsync.isLoading || programsAsync.isLoading || consistencyAsync.isLoading) {
      return achievements;
    }

    final history = historyAsync.value ?? [];
    final overview = overviewAsync.value;
    final programs = programsAsync.value ?? [];
    final consistency = consistencyAsync.value ?? 0.0;

    if (overview == null) return achievements;

    int totalSets = 0;
    for (final session in history) {
      for (final ex in session.workout.exercises) {
        totalSets += ex.sets.where((s) => s.isCompleted).length;
      }
    }

    bool changed = false;
    final updated = achievements.map((a) {
      if (a.isUnlocked) return a;

      bool shouldUnlock = false;
      switch (a.id) {
        case 'first_workout':
          shouldUnlock = history.isNotEmpty;
          break;
        case 'streak_7':
          shouldUnlock = overview.longestStreak >= 7;
          break;
        case 'sets_50':
          shouldUnlock = totalSets >= 50;
          break;
        case 'sessions_100':
          shouldUnlock = history.length >= 100;
          break;
        case 'first_program':
          shouldUnlock = programs.isNotEmpty;
          break;
        case 'pr_10':
          int prCount = 0;
          final exerciseBests = <String, double>{};
          final sortedHistory = List<dynamic>.from(history)..sort((a, b) => a.startTime.compareTo(b.startTime));
          for (final session in sortedHistory) {
             for (final ex in session.workout.exercises) {
               for (final set in ex.sets) {
                 if (set.isCompleted) {
                   final currentBest = exerciseBests[ex.exercise.id] ?? 0;
                   if (set.weight > currentBest) {
                     prCount++;
                     exerciseBests[ex.exercise.id] = set.weight;
                   }
                 }
               }
             }
          }
          shouldUnlock = prCount >= 10;
          break;
        case 'consistency_master':
          shouldUnlock = consistency >= 0.8;
          break;
      }

      if (shouldUnlock) {
        changed = true;
        return a.copyWith(unlockedAt: DateTime.now());
      }
      return a;
    }).toList();

    if (changed) {
      final repo = ref.read(goalRepositoryProvider);
      for (final a in updated) {
        if (a.isUnlocked) await repo.saveAchievement(a);
      }
    }
    return updated;
  }
}

final achievementProvider = AsyncNotifierProvider<AchievementNotifier, List<Achievement>>(() {
  return AchievementNotifier();
});

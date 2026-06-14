import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/monitoring/user_behavior_tracker.dart';
import '../data/workout_repository.dart';
import '../domain/exercise.dart';
import '../domain/workout.dart';
import '../domain/workout_set.dart';
import '../domain/workout_session.dart';

/// Provider for the [WorkoutRepository] implementation.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  throw UnimplementedError('workoutRepositoryProvider must be overridden with SharedPreferences');
});

/// Notifier for managing the list of workouts.
class WorkoutListNotifier extends AsyncNotifier<List<Workout>> {
  @override
  Future<List<Workout>> build() async {
    return ref.read(workoutRepositoryProvider).getWorkouts();
  }

  Future<void> addWorkout(Workout workout) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.createWorkout(workout);
      return repo.getWorkouts();
    });
  }

  Future<void> deleteWorkout(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteWorkout(id);
      return repo.getWorkouts();
    });
  }

  Future<void> addExerciseToWorkout(String workoutId, Exercise exercise) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(workoutRepositoryProvider);
      final workouts = await repo.getWorkouts();
      final index = workouts.indexWhere((w) => w.id == workoutId);
      
      if (index != -1) {
        final workout = workouts[index];
        final updatedExercises = List<WorkoutExercise>.from(workout.exercises)
          ..add(WorkoutExercise(exercise: exercise, sets: []));
        
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);
        await repo.updateWorkout(updatedWorkout);
      }
      
      return repo.getWorkouts();
    });
  }
}

/// Provider for the list of workouts.
final workoutListProvider = AsyncNotifierProvider<WorkoutListNotifier, List<Workout>>(() {
  return WorkoutListNotifier();
});

/// Notifier for managing the active [WorkoutSession].
class ActiveSessionNotifier extends Notifier<WorkoutSession?> {
  @override
  WorkoutSession? build() {
    _restoreSession();
    return null;
  }

  Future<void> _restoreSession() async {
    final repo = ref.read(workoutRepositoryProvider);
    final session = await repo.getActiveSession();
    if (session != null) {
      state = session;
    }
  }

  Future<void> startSession(Workout workout) async {
    if (state != null) return; // Prevent duplicate sessions

    final session = WorkoutSession(
      id: DateTime.now().toIso8601String(),
      workout: workout,
      startTime: DateTime.now(),
    );
    
    final repo = ref.read(workoutRepositoryProvider);
    await repo.startSession(session);
    await repo.saveActiveSession(session);
    state = session;

    ref.read(userBehaviorTrackerProvider).logEvent('workout_start');
  }

  Future<WorkoutSession?> endSession() async {
    if (state == null) return null;
    
    final completedSession = state!.copyWith(endTime: DateTime.now());
    final repo = ref.read(workoutRepositoryProvider);
    await repo.endSession(completedSession);
    await repo.saveActiveSession(null);
    state = null;

    final duration = completedSession.endTime!.difference(completedSession.startTime);
    ref.read(userBehaviorTrackerProvider).logEvent('session_complete', parameters: {
      'duration_seconds': duration.inSeconds,
    });

    return completedSession;
  }

  void updateSet(int exerciseIndex, int setIndex, WorkoutSet updatedSet) {
    if (state == null) return;

    // Validate inputs
    final validatedSet = updatedSet.copyWith(
      reps: updatedSet.reps < 0 ? 0 : updatedSet.reps,
      weight: updatedSet.weight < 0 ? 0.0 : updatedSet.weight,
    );

    final workout = state!.workout;
    final exercises = List<WorkoutExercise>.from(workout.exercises);
    final workoutExercise = exercises[exerciseIndex];
    final sets = List<WorkoutSet>.from(workoutExercise.sets);
    
    sets[setIndex] = validatedSet;
    exercises[exerciseIndex] = workoutExercise.copyWith(sets: sets);
    
    final newState = state!.copyWith(
      workout: workout.copyWith(exercises: exercises),
    );
    
    state = newState;
    _autosave(newState);
  }

  void addSet(int exerciseIndex) {
    if (state == null) return;

    final workout = state!.workout;
    final exercises = List<WorkoutExercise>.from(workout.exercises);
    final workoutExercise = exercises[exerciseIndex];
    final sets = List<WorkoutSet>.from(workoutExercise.sets);
    
    final lastSet = sets.isNotEmpty ? sets.last : null;
    sets.add(WorkoutSet(
      reps: lastSet?.reps ?? 10,
      weight: lastSet?.weight ?? 0.0,
      isCompleted: false,
    ));
    
    exercises[exerciseIndex] = workoutExercise.copyWith(sets: sets);
    
    final newState = state!.copyWith(
      workout: workout.copyWith(exercises: exercises),
    );
    
    state = newState;
    _autosave(newState);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (state == null) return;

    final workout = state!.workout;
    final exercises = List<WorkoutExercise>.from(workout.exercises);
    final workoutExercise = exercises[exerciseIndex];
    final sets = List<WorkoutSet>.from(workoutExercise.sets);
    
    sets.removeAt(setIndex);
    exercises[exerciseIndex] = workoutExercise.copyWith(sets: sets);
    
    final newState = state!.copyWith(
      workout: workout.copyWith(exercises: exercises),
    );
    
    state = newState;
    _autosave(newState);
  }

  Future<void> _autosave(WorkoutSession session) async {
    await ref.read(workoutRepositoryProvider).saveActiveSession(session);
  }
}

/// Provider for the active workout session.
final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, WorkoutSession?>(() {
  return ActiveSessionNotifier();
});

/// Notifier for managing the workout history.
class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  Future<List<WorkoutSession>> build() async {
    final sessions = await ref.read(workoutRepositoryProvider).getSessionHistory();
    return sessions.where((s) => s.isCompleted).toList().reversed.toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(workoutRepositoryProvider).getSessionHistory().then(
      (sessions) => sessions.where((s) => s.isCompleted).toList().reversed.toList()
    ));
  }
}

/// Provider for the workout history.
final workoutHistoryProvider = AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutSession>>(() {
  return WorkoutHistoryNotifier();
});

/// Provider for workout statistics.
final workoutStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  
  return historyAsync.whenData((history) {
    final totalWorkouts = history.length;
    final totalSets = history.fold<int>(0, (sum, session) {
      return sum + session.workout.exercises.fold<int>(0, (eSum, e) {
        return eSum + e.sets.where((s) => s.isCompleted).length;
      });
    });
    
    return {
      'totalWorkouts': totalWorkouts,
      'totalSets': totalSets,
    };
  });
});

/// Provider to get the personal record for a specific exercise.
final exercisePRProvider = Provider.family<WorkoutSet?, String>((ref, exerciseId) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.maybeWhen(
    data: (history) {
      WorkoutSet? bestSet;
      for (final session in history) {
        for (final exercise in session.workout.exercises) {
          if (exercise.exercise.id == exerciseId) {
            for (final set in exercise.sets) {
              if (set.isCompleted) {
                if (bestSet == null || 
                    set.weight > bestSet.weight || 
                    (set.weight == bestSet.weight && set.reps > bestSet.reps)) {
                  bestSet = set;
                }
              }
            }
          }
        }
      }
      return bestSet;
    },
    orElse: () => null,
  );
});

/// Provider to get the last session performance for a specific exercise.
final lastExercisePerformanceProvider = Provider.family<List<WorkoutSet>?, String>((ref, exerciseId) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.maybeWhen(
    data: (history) {
      for (final session in history) {
        for (final exercise in session.workout.exercises) {
          if (exercise.exercise.id == exerciseId && exercise.sets.any((s) => s.isCompleted)) {
            return exercise.sets;
          }
        }
      }
      return null;
    },
    orElse: () => null,
  );
});

/// Provider for workout streak.
final workoutStreakProvider = Provider<AsyncValue<int>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.whenData((history) {
    if (history.isEmpty) return 0;
    
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);
    
    final sessionDates = history.map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toSet().toList();
    sessionDates.sort((a, b) => b.compareTo(a));

    if (sessionDates.isEmpty) return 0;
    
    // Check if the latest session was today or yesterday
    if (sessionDates.first.isBefore(checkDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    for (int i = 0; i < sessionDates.length; i++) {
      final expectedDate = i == 0 ? sessionDates.first : sessionDates.first.subtract(Duration(days: i));
      if (sessionDates.any((d) => d.year == expectedDate.year && d.month == expectedDate.month && d.day == expectedDate.day)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  });
});

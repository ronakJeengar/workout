import '../domain/workout.dart';
import '../domain/workout_session.dart';
import 'workout_repository.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final List<Workout> _workouts = [];
  final List<WorkoutSession> _sessions = [];
  WorkoutSession? _activeSession;

  @override
  Future<void> createWorkout(Workout workout) async {
    _workouts.add(workout);
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    return List.unmodifiable(_workouts);
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> startSession(WorkoutSession session) async {
    _sessions.add(session);
    _activeSession = session;
  }

  @override
  Future<void> endSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    }
    _activeSession = null;
  }

  @override
  Future<List<WorkoutSession>> getSessionHistory() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<WorkoutSession?> getActiveSession() async => _activeSession;

  @override
  Future<void> saveActiveSession(WorkoutSession? session) async {
    _activeSession = session;
  }
}

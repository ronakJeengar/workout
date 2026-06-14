import '../domain/workout.dart';
import '../domain/workout_session.dart';

abstract class WorkoutRepository {
  Future<void> createWorkout(Workout workout);
  Future<List<Workout>> getWorkouts();
  Future<void> updateWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
  
  Future<void> startSession(WorkoutSession session);
  Future<void> endSession(WorkoutSession session);
  Future<List<WorkoutSession>> getSessionHistory();

  // Phase 2: Session Recovery
  Future<WorkoutSession?> getActiveSession();
  Future<void> saveActiveSession(WorkoutSession? session);
}
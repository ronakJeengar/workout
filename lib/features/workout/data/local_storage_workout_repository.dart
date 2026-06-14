import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/monitoring/data_integrity_service.dart';
import '../domain/workout.dart';
import '../domain/workout_session.dart';
import 'workout_repository.dart';

class LocalStorageWorkoutRepository implements WorkoutRepository {
  static const String _workoutsKey = 'workouts_v1';
  static const String _sessionsKey = 'sessions_v1';
  static const String _activeSessionKey = 'active_session_v1';
  static const int _currentSchemaVersion = 1;
  
  final SharedPreferences _prefs;
  final DataIntegrityService? _watchdog;

  LocalStorageWorkoutRepository(this._prefs, [this._watchdog]);

  @override
  Future<WorkoutSession?> getActiveSession() async {
    try {
      final String? data = _prefs.getString(_activeSessionKey);
      if (data == null) return null;
      
      final Map<String, dynamic> envelope = jsonDecode(data);
      return WorkoutSession.fromJson(envelope['data'] as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveActiveSession(WorkoutSession? session) async {
    if (session == null) {
      await _prefs.remove(_activeSessionKey);
      return;
    }
    
    final envelope = {
      'version': _currentSchemaVersion,
      'data': session.toJson(),
    };
    await _prefs.setString(_activeSessionKey, jsonEncode(envelope));
  }

  @override
  Future<void> createWorkout(Workout workout) async {
    final workouts = await getWorkouts();
    workouts.add(workout);
    await _saveWorkouts(workouts);
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    try {
      final String? data = _prefs.getString(_workoutsKey);
      if (data == null) return [];
      
      final Map<String, dynamic> envelope = jsonDecode(data);
      final int version = envelope['version'] as int? ?? 1;
      _watchdog?.detectSchemaDrift(version, _currentSchemaVersion, _workoutsKey);

      final List decoded = envelope['data'] as List;
      final watchdog = _watchdog;
      if (watchdog != null) {
        return watchdog.isolateCorruptedEntries<Workout>(
          rawData: decoded,
          fromJson: (w) => Workout.fromJson(w),
          contextKey: _workoutsKey,
        );
      }
      return decoded.map((w) => Workout.fromJson(w as Map<String, dynamic>)).toList();
    } catch (e) {
      // Recovery: fallback to empty list on corruption or schema mismatch
      return [];
    }
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final workouts = await getWorkouts();
    final index = workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      workouts[index] = workout;
      await _saveWorkouts(workouts);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    final workouts = await getWorkouts();
    workouts.removeWhere((w) => w.id == id);
    await _saveWorkouts(workouts);
  }

  @override
  Future<void> startSession(WorkoutSession session) async {
    final sessions = await _getAllSessions();
    sessions.add(session);
    await _saveSessions(sessions);
  }

  @override
  Future<void> endSession(WorkoutSession session) async {
    final sessions = await _getAllSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
      await _saveSessions(sessions);
    }
  }

  @override
  Future<List<WorkoutSession>> getSessionHistory() async {
    return _getAllSessions();
  }

  Future<List<WorkoutSession>> _getAllSessions() async {
    try {
      final String? data = _prefs.getString(_sessionsKey);
      if (data == null) return [];
      
      final Map<String, dynamic> envelope = jsonDecode(data);
      final int version = envelope['version'] as int? ?? 1;
      _watchdog?.detectSchemaDrift(version, _currentSchemaVersion, _sessionsKey);

      final List decoded = envelope['data'] as List;
      final watchdog = _watchdog;
      if (watchdog != null) {
        return watchdog.isolateCorruptedEntries<WorkoutSession>(
          rawData: decoded,
          fromJson: (s) => WorkoutSession.fromJson(s),
          contextKey: _sessionsKey,
        );
      }
      return decoded.map((s) => WorkoutSession.fromJson(s as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveWorkouts(List<Workout> workouts) async {
    final envelope = {
      'version': _currentSchemaVersion,
      'data': workouts.map((w) => w.toJson()).toList(),
    };
    await _prefs.setString(_workoutsKey, jsonEncode(envelope));
  }

  Future<void> _saveSessions(List<WorkoutSession> sessions) async {
    final envelope = {
      'version': _currentSchemaVersion,
      'data': sessions.map((s) => s.toJson()).toList(),
    };
    await _prefs.setString(_sessionsKey, jsonEncode(envelope));
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import '../../programs/data/program_repository.dart';
import '../../programs/data/isar_program.dart';
import '../../programs/domain/program.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout_session.dart';
import '../domain/generated_program.dart';

class AutoProgramRepository {
  final Isar _isar;
  final SharedPreferences _prefs;

  AutoProgramRepository(this._isar, this._prefs);

  Future<void> saveGeneratedProgram({
    required GeneratedProgram generated,
    required ProgramRepository programRepo,
    required WorkoutRepository workoutRepo,
  }) async {
    // 1. Save all generated workouts in the workout database so they can be selected/tracked
    for (final day in generated.weeklyPlan) {
      await workoutRepo.createWorkout(day.workout);
    }

    // 2. Convert to list of ScheduledWorkouts
    final scheduledWorkouts = <ScheduledWorkout>[];
    for (int i = 0; i < generated.weeklyPlan.length; i++) {
      final day = generated.weeklyPlan[i];
      scheduledWorkouts.add(ScheduledWorkout(
        workoutId: day.workout.id,
        dayOfWeek: i + 1, // 1-indexed days
        order: 0,
      ));
    }

    // 3. Serialize metadata into description JSON
    final metadata = {
      'isGenerated': true,
      'adaptationReason': generated.adaptationReason,
      'estimatedDifficulty': generated.estimatedDifficulty,
      'templateId': generated.templateUsed.id,
      'createdAt': generated.createdAt.toIso8601String(),
    };

    final program = Program(
      id: generated.id,
      name: '[AI COACH] ${generated.templateUsed.name}',
      description: jsonEncode(metadata),
      workouts: scheduledWorkouts,
      createdAt: generated.createdAt,
      updatedAt: generated.createdAt,
    );

    // 4. Save to standard Program Repository (SharedPreferences / existing logic)
    await programRepo.createProgram(program);

    // 5. Save to Isar database (for local persistence offline backup)
    final isarProgram = IsarProgram()
      ..originalId = program.id
      ..name = program.name
      ..description = program.description
      ..workouts = program.workouts.map((w) => IsarScheduledWorkout()
        ..workoutId = w.workoutId
        ..dayOfWeek = w.dayOfWeek
        ..order = w.order
      ).toList()
      ..createdAt = program.createdAt
      ..updatedAt = program.updatedAt;

    await _isar.writeTxn(() async {
      await _isar.isarPrograms.putByOriginalId(isarProgram);
    });

    // 6. Track generated program ID
    final List<String> list = _prefs.getStringList('generated_program_ids') ?? [];
    list.add(generated.id);
    await _prefs.setStringList('generated_program_ids', list);
  }

  Future<List<String>> getGeneratedProgramIds() async {
    return _prefs.getStringList('generated_program_ids') ?? [];
  }

  double calculateAdherence(Program program, List<WorkoutSession> history) {
    if (program.workouts.isEmpty) return 1.0;

    final last7Days = DateTime.now().subtract(const Duration(days: 7));
    final recentSessions = history.where((s) => s.startTime.isAfter(last7Days)).toList();

    int completedCount = 0;
    for (final scheduled in program.workouts) {
      final matched = recentSessions.any((s) => s.workout.id == scheduled.workoutId);
      if (matched) {
        completedCount++;
      }
    }

    return (completedCount / program.workouts.length).clamp(0.0, 1.0);
  }
}

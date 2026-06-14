import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/program.dart';
import '../domain/weekly_split_generator.dart';
import '../data/program_repository.dart';

final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  throw UnimplementedError('programRepositoryProvider must be overridden');
});

class ProgramListNotifier extends AsyncNotifier<List<Program>> {
  @override
  Future<List<Program>> build() async {
    return ref.read(programRepositoryProvider).getPrograms();
  }

  Future<void> createProgram(String name, {String description = ''}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final program = Program(
        id: DateTime.now().toIso8601String(),
        name: name,
        description: description,
        workouts: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.createProgram(program);
      return repo.getPrograms();
    });
  }

  Future<void> updateProgram(Program program) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final updated = program.copyWith(updatedAt: DateTime.now());
      await repo.updateProgram(updated);
      return repo.getPrograms();
    });
  }

  Future<void> deleteProgram(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      await repo.deleteProgram(id);
      return repo.getPrograms();
    });
  }

  Future<void> duplicateProgram(Program program) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final duplicated = Program(
        id: DateTime.now().toIso8601String(),
        name: '${program.name} (Copy)',
        description: program.description,
        workouts: program.workouts,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.createProgram(duplicated);
      return repo.getPrograms();
    });
  }

  Future<void> scheduleWorkout(String programId, String workoutId, int dayOfWeek) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final programs = await repo.getPrograms();
      final index = programs.indexWhere((p) => p.id == programId);
      
      if (index != -1) {
        final program = programs[index];
        final dayWorkouts = program.workouts.where((w) => w.dayOfWeek == dayOfWeek).toList();
        final newWorkout = ScheduledWorkout(
          workoutId: workoutId,
          dayOfWeek: dayOfWeek,
          order: dayWorkouts.length,
        );
        final updatedWorkouts = List<ScheduledWorkout>.from(program.workouts)..add(newWorkout);
        final updatedProgram = program.copyWith(workouts: updatedWorkouts);
        await repo.updateProgram(updatedProgram);
      }
      return repo.getPrograms();
    });
  }

  Future<void> reorderWorkout(String programId, int dayOfWeek, int oldIndex, int newIndex) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final programs = await repo.getPrograms();
      final index = programs.indexWhere((p) => p.id == programId);

      if (index != -1) {
        final program = programs[index];
        final dayWorkouts = program.workouts.where((w) => w.dayOfWeek == dayOfWeek).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = dayWorkouts.removeAt(oldIndex);
        dayWorkouts.insert(newIndex, item);

        // Update orders
        final updatedDayWorkouts = dayWorkouts.asMap().entries.map((e) => e.value.copyWith(order: e.key)).toList();
        
        // Merge back into program workouts
        final otherWorkouts = program.workouts.where((w) => w.dayOfWeek != dayOfWeek).toList();
        final finalWorkouts = [...otherWorkouts, ...updatedDayWorkouts];
        
        final updatedProgram = program.copyWith(workouts: finalWorkouts);
        await repo.updateProgram(updatedProgram);
      }
      return repo.getPrograms();
    });
  }

  Future<void> generateWeeklySplit({
    required String goal,
    required double recoveryScore,
    required List<String> availableWorkoutIds,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(programRepositoryProvider);
      final generator = ref.read(weeklySplitGeneratorProvider);
      final program = generator.generate(
        goal: goal,
        recoveryScore: recoveryScore,
        availableWorkoutIds: availableWorkoutIds,
      );
      await repo.createProgram(program);
      return repo.getPrograms();
    });
  }
}

final programListProvider = AsyncNotifierProvider<ProgramListNotifier, List<Program>>(() {
  return ProgramListNotifier();
});

final weeklySplitGeneratorProvider = Provider<WeeklySplitGenerator>((ref) {
  return const WeeklySplitGenerator();
});

final selectedProgramProvider = StateProvider<Program?>((ref) => null);

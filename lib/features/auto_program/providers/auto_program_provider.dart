import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database.dart';
import '../../../core/monitoring/crash_triage.dart';
import '../../workout/providers/workout_providers.dart';
import '../../progress/providers/progress_provider.dart';
import '../../goals/providers/goal_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../../coach/providers/coach_providers.dart';
import '../../programs/providers/program_providers.dart';
import '../domain/generated_program.dart';
import '../data/program_generator_engine.dart';
import '../data/auto_program_repository.dart';

/// Exposes the AutoProgramRepository.
final autoProgramRepositoryProvider = Provider<AutoProgramRepository>((ref) {
  final isar = ref.watch(isarProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoProgramRepository(isar, prefs);
});

/// Exposes the core ProgramGeneratorEngine.
final programGeneratorProvider = Provider<ProgramGeneratorEngine>((ref) {
  return const ProgramGeneratorEngine();
});

/// Dynamically generates a customized program based on training history, fatigue status, and progression.
final generatedProgramProvider = FutureProvider<GeneratedProgram>((ref) async {
  final history = await ref.watch(workoutHistoryProvider.future);
  final fatigue = await ref.watch(fatigueProvider.future);
  final overview = ref.watch(progressOverviewProvider).value;
  final goals = await ref.watch(goalListProvider.future);
  final settings = ref.watch(settingsProvider);
  
  // Watching consistency score
  final consistencyAsync = ref.watch(consistencyProvider);
  final consistency = consistencyAsync.value ?? 0.5;

  if (overview == null) {
    throw const AsyncValue.loading();
  }

  final engine = ref.read(programGeneratorProvider);
  return engine.generate(
    history: history,
    overview: overview,
    consistencyScore: consistency,
    fatigue: fatigue,
    goals: goals,
    settings: settings,
  );
});

/// Exposes the current adaptation reason.
final programAdaptationProvider = Provider<AsyncValue<String>>((ref) {
  final generatedAsync = ref.watch(generatedProgramProvider);
  return generatedAsync.whenData((p) => p.adaptationReason);
});

/// State notifier to handle saving generated programs to Isar & SharedPreferences.
class AutoProgramNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AutoProgramNotifier(this.ref) : super(const AsyncData(null));

  Future<void> saveCurrentGeneratedProgram() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final generated = await ref.read(generatedProgramProvider.future);
      final repo = ref.read(autoProgramRepositoryProvider);
      final programRepo = ref.read(programRepositoryProvider);
      final workoutRepo = ref.read(workoutRepositoryProvider);

      await repo.saveGeneratedProgram(
        generated: generated,
        programRepo: programRepo,
        workoutRepo: workoutRepo,
      );

      // Invalidate the main program list provider to refresh UI automatically
      ref.invalidate(programListProvider);
    });
  }
}

final autoProgramNotifierProvider = StateNotifierProvider<AutoProgramNotifier, AsyncValue<void>>((ref) {
  return AutoProgramNotifier(ref);
});

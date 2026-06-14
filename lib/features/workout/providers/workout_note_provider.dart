import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database.dart';
import '../data/isar_workout_note.dart';
import '../data/workout_note_repository.dart';

final workoutNoteRepositoryProvider = Provider<WorkoutNoteRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return WorkoutNoteRepository(isar);
});

class WorkoutNoteNotifier extends FamilyAsyncNotifier<IsarWorkoutNote?, String> {
  @override
  Future<IsarWorkoutNote?> build(String arg) async {
    final repo = ref.read(workoutNoteRepositoryProvider);
    return repo.getNoteForSession(arg);
  }

  Future<void> saveNote({
    required String notes,
    required List<IsarExerciseNote> exerciseNotes,
    required String mood,
    required int subjectiveEffort,
  }) async {
    final repo = ref.read(workoutNoteRepositoryProvider);
    final existing = state.value;
    final note = IsarWorkoutNote()
      ..sessionId = arg
      ..notes = notes
      ..exerciseNotes = exerciseNotes
      ..mood = mood
      ..subjectiveEffort = subjectiveEffort;
    if (existing != null) {
      note.id = existing.id;
    }
    await repo.saveNote(note);
    state = AsyncData(note);
  }
}

final workoutNoteProvider = AsyncNotifierProviderFamily<WorkoutNoteNotifier, IsarWorkoutNote?, String>(() {
  return WorkoutNoteNotifier();
});

import 'package:isar/isar.dart';
import 'isar_workout_note.dart';

class WorkoutNoteRepository {
  final Isar _isar;

  WorkoutNoteRepository(this._isar);

  Future<IsarWorkoutNote?> getNoteForSession(String sessionId) async {
    return _isar.isarWorkoutNotes.filter().sessionIdEqualTo(sessionId).findFirst();
  }

  Future<void> saveNote(IsarWorkoutNote note) async {
    await _isar.writeTxn(() async {
      await _isar.isarWorkoutNotes.put(note);
    });
  }

  Future<List<IsarWorkoutNote>> getAllNotes() async {
    return _isar.isarWorkoutNotes.where().findAll();
  }
}

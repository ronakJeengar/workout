import 'package:isar/isar.dart';

part 'isar_workout_note.g.dart';

@collection
class IsarWorkoutNote {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sessionId;

  late String notes;
  late List<IsarExerciseNote> exerciseNotes;
  late String mood; // Emoji-based mood representation
  late int subjectiveEffort; // Subjective effort rating (1-10)

  IsarWorkoutNote();
}

@embedded
class IsarExerciseNote {
  late String exerciseId;
  late String note;

  IsarExerciseNote();
}

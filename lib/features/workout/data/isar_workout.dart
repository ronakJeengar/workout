import 'package:isar/isar.dart';

part 'isar_workout.g.dart';

@collection
class IsarWorkout {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String originalId;
  
  late String name;
  late String description;
  late List<IsarWorkoutExercise> exercises;
}

@embedded
class IsarWorkoutExercise {
  late String exerciseId;
  late String exerciseName;
  late List<IsarWorkoutSet> sets;
}

@embedded
class IsarWorkoutSet {
  late int reps;
  late double weight;
  late bool isCompleted;
  late int? restTimeSeconds;
}

@collection
class IsarWorkoutSession {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String originalId;
  
  final workout = IsarLink<IsarWorkout>();
  late DateTime startTime;
  late DateTime? endTime;
}

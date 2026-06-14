import 'package:isar/isar.dart';

part 'isar_program.g.dart';

@collection
class IsarProgram {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String originalId;
  
  late String name;
  late String description;
  late List<IsarScheduledWorkout> workouts;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@embedded
class IsarScheduledWorkout {
  late String workoutId;
  late int dayOfWeek;
  late int order;
}

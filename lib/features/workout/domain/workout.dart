import 'exercise.dart';
import 'workout_set.dart';

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
  });

  WorkoutExercise copyWith({
    Exercise? exercise,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class Workout {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;

  const Workout({
    required this.id,
    required this.name,
    required this.exercises,
  });

  Workout copyWith({
    String? id,
    String? name,
    List<WorkoutExercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List).map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

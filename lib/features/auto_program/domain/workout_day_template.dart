import 'exercise_template.dart';

class WorkoutDayTemplate {
  final String dayName;
  final List<String> muscleGroups;
  final List<ExerciseTemplate> exercises;

  const WorkoutDayTemplate({
    required this.dayName,
    required this.muscleGroups,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'muscleGroups': muscleGroups,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutDayTemplate.fromJson(Map<String, dynamic> json) => WorkoutDayTemplate(
    dayName: json['dayName'] as String,
    muscleGroups: List<String>.from(json['muscleGroups'] as List),
    exercises: (json['exercises'] as List)
        .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

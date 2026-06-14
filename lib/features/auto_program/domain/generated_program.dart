import 'program_template.dart';
import '../../workout/domain/workout.dart';

class WorkoutDay {
  final String dayName;
  final Workout workout;

  const WorkoutDay({
    required this.dayName,
    required this.workout,
  });

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'workout': workout.toJson(),
  };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
    dayName: json['dayName'] as String,
    workout: Workout.fromJson(json['workout'] as Map<String, dynamic>),
  );
}

class GeneratedProgram {
  final String id;
  final ProgramTemplate templateUsed;
  final String adaptationReason;
  final List<WorkoutDay> weeklyPlan;
  final double estimatedDifficulty;
  final DateTime createdAt;

  const GeneratedProgram({
    required this.id,
    required this.templateUsed,
    required this.adaptationReason,
    required this.weeklyPlan,
    required this.estimatedDifficulty,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateUsed': templateUsed.toJson(),
    'adaptationReason': adaptationReason,
    'weeklyPlan': weeklyPlan.map((wp) => wp.toJson()).toList(),
    'estimatedDifficulty': estimatedDifficulty,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GeneratedProgram.fromJson(Map<String, dynamic> json) => GeneratedProgram(
    id: json['id'] as String,
    templateUsed: ProgramTemplate.fromJson(json['templateUsed'] as Map<String, dynamic>),
    adaptationReason: json['adaptationReason'] as String,
    weeklyPlan: (json['weeklyPlan'] as List)
        .map((wp) => WorkoutDay.fromJson(wp as Map<String, dynamic>))
        .toList(),
    estimatedDifficulty: (json['estimatedDifficulty'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

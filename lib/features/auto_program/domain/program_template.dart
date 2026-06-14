// ignore_for_file: constant_identifier_names

import 'workout_day_template.dart';

enum ProgramGoalType { muscle_gain, strength, fat_loss, general }

class ProgramTemplate {
  final String id;
  final String name; // Push / Pull / Legs / Full Body / Upper-Lower
  final ProgramGoalType goalType;
  final String level; // beginner | intermediate | advanced
  final int daysPerWeek;
  final List<WorkoutDayTemplate> splitStructure;

  const ProgramTemplate({
    required this.id,
    required this.name,
    required this.goalType,
    required this.level,
    required this.daysPerWeek,
    required this.splitStructure,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'goalType': goalType.name,
    'level': level,
    'daysPerWeek': daysPerWeek,
    'splitStructure': splitStructure.map((s) => s.toJson()).toList(),
  };

  factory ProgramTemplate.fromJson(Map<String, dynamic> json) => ProgramTemplate(
    id: json['id'] as String,
    name: json['name'] as String,
    goalType: ProgramGoalType.values.firstWhere((e) => e.name == json['goalType']),
    level: json['level'] as String,
    daysPerWeek: json['daysPerWeek'] as int,
    splitStructure: (json['splitStructure'] as List)
        .map((s) => WorkoutDayTemplate.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

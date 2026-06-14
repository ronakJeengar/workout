import 'workout.dart';

class WorkoutSession {
  final String id;
  final Workout workout;
  final DateTime startTime;
  final DateTime? endTime;

  const WorkoutSession({
    required this.id,
    required this.workout,
    required this.startTime,
    this.endTime,
  });

  bool get isCompleted => endTime != null;

  WorkoutSession copyWith({
    String? id,
    Workout? workout,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workout: workout ?? this.workout,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout': workout.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      workout: Workout.fromJson(json['workout'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    );
  }
}

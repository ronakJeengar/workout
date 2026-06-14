class Program {
  final String id;
  final String name;
  final String description;
  final List<ScheduledWorkout> workouts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Program({
    required this.id,
    required this.name,
    this.description = '',
    required this.workouts,
    required this.createdAt,
    required this.updatedAt,
  });

  Program copyWith({
    String? name,
    String? description,
    List<ScheduledWorkout>? workouts,
    DateTime? updatedAt,
  }) {
    return Program(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      workouts: workouts ?? this.workouts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      workouts: (json['workouts'] as List)
          .map((w) => ScheduledWorkout.fromJson(w as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ScheduledWorkout {
  final String workoutId;
  final int dayOfWeek; // 1-7
  final int order;

  const ScheduledWorkout({
    required this.workoutId,
    required this.dayOfWeek,
    required this.order,
  });

  ScheduledWorkout copyWith({
    String? workoutId,
    int? dayOfWeek,
    int? order,
  }) {
    return ScheduledWorkout(
      workoutId: workoutId ?? this.workoutId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'dayOfWeek': dayOfWeek,
      'order': order,
    };
  }

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      workoutId: json['workoutId'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      order: json['order'] as int,
    );
  }
}

class WorkoutSet {
  final int reps;
  final double weight;
  final bool isCompleted;
  final Duration? restTime;

  const WorkoutSet({
    required int reps,
    required double weight,
    this.isCompleted = false,
    this.restTime,
  })  : reps = reps < 0 ? 0 : reps,
        weight = weight < 0 ? 0.0 : weight;

  WorkoutSet copyWith({
    int? reps,
    double? weight,
    bool? isCompleted,
    Duration? restTime,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      restTime: restTime ?? this.restTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'restTime': restTime?.inSeconds,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    final int reps = json['reps'] as int;
    final double weight = (json['weight'] as num).toDouble();
    return WorkoutSet(
      reps: reps < 0 ? 0 : reps,
      weight: weight < 0 ? 0.0 : weight,
      isCompleted: json['isCompleted'] as bool,
      restTime: json['restTime'] != null ? Duration(seconds: json['restTime'] as int) : null,
    );
  }
}

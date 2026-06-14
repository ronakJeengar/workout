class ExerciseTemplate {
  final String exerciseId;
  final String setsRange;
  final String repsRange;
  final String intensityType; // strength | hypertrophy | endurance

  const ExerciseTemplate({
    required this.exerciseId,
    required this.setsRange,
    required this.repsRange,
    required this.intensityType,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'setsRange': setsRange,
    'repsRange': repsRange,
    'intensityType': intensityType,
  };

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) => ExerciseTemplate(
    exerciseId: json['exerciseId'] as String,
    setsRange: json['setsRange'] as String,
    repsRange: json['repsRange'] as String,
    intensityType: json['intensityType'] as String,
  );
}

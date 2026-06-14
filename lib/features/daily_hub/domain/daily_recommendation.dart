enum TrainingDecision { train, rest, lightDay }

enum FatigueStatus { critical, moderate, low }

class ReadinessScore {
  final double value; // 0.0 - 1.0

  const ReadinessScore(this.value);
}

class DailyRecommendation {
  final TrainingDecision decision;
  final String recommendedWorkoutType;
  final String intensityLevel; // LOW / MEDIUM / HIGH
  final String primaryMuscleGroup;
  final int confidenceScore; // 0-100
  final String explanation;

  const DailyRecommendation({
    required this.decision,
    required this.recommendedWorkoutType,
    required this.intensityLevel,
    required this.primaryMuscleGroup,
    required this.confidenceScore,
    required this.explanation,
  });
}

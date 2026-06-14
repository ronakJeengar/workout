enum CoachRecommendationType { insight, warning, suggestion, achievement }

enum RecommendationIntensity { low, medium, high }

class CoachRecommendation {
  final String title;
  final String message;
  final CoachRecommendationType type;
  final RecommendationIntensity intensity;
  final DateTime timestamp;

  const CoachRecommendation({
    required this.title,
    required this.message,
    required this.type,
    required this.intensity,
    required this.timestamp,
  });
}

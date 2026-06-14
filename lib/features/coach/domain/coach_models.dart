enum InsightType { improvement, caution, recommendation }

class CoachInsight {
  final String title;
  final String message;
  final InsightType type;
  final String? exerciseId;

  const CoachInsight({
    required this.title,
    required this.message,
    required this.type,
    this.exerciseId,
  });
}

class RecoveryStatus {
  final double score; // 0.0 - 1.0
  final String label; // Ready, Moderate, Recover
  final String description;

  const RecoveryStatus({
    required this.score,
    required this.label,
    required this.description,
  });
}

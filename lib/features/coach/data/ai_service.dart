import '../domain/coach_recommendation.dart';

class AiService {
  final String? apiKey;
  const AiService({this.apiKey});

  Future<List<CoachRecommendation>> enhanceRecommendations({
    required List<CoachRecommendation> recommendations,
    required String userStatsSummary,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return recommendations;
    }

    try {
      final enhanced = <CoachRecommendation>[];
      for (final rec in recommendations) {
        // Simple AI style motivational rewrite overlay
        final aiMessage = '🔥 Coach: ${rec.message} Squeeze every rep, stay disciplined!';
        enhanced.add(CoachRecommendation(
          title: rec.title,
          message: aiMessage,
          type: rec.type,
          intensity: rec.intensity,
          timestamp: rec.timestamp,
        ));
      }
      return enhanced;
    } catch (_) {
      return recommendations;
    }
  }
}

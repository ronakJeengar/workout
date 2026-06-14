import '../../workout/domain/workout_session.dart';

class AdaptationOutput {
  final String recommendedIntensity;
  final bool suggestRestDay;
  final List<String> warningSignals;

  const AdaptationOutput({
    required this.recommendedIntensity,
    required this.suggestRestDay,
    required this.warningSignals,
  });
}

class AdaptiveTrainingService {
  const AdaptiveTrainingService();

  AdaptationOutput analyze({
    required List<WorkoutSession> history,
    required int streak,
    required double prFrequency,
    required int missedSessions,
    required double recoveryScore,
  }) {
    final warnings = <String>[];
    String intensity = 'Normal';
    bool restDay = false;

    if (recoveryScore < 0.4) {
      warnings.add('Critical fatigue detected. Recovery score is low ($recoveryScore).');
      intensity = 'Deload';
      restDay = true;
    } else if (recoveryScore < 0.75) {
      warnings.add('Moderate fatigue. Consider a deload or reduced volume.');
      intensity = 'Deload';
    }

    if (streak > 5) {
      warnings.add('High training streak of $streak days. Rest is advised.');
      restDay = true;
      intensity = 'Deload';
    }

    if (history.isNotEmpty && prFrequency < 0.15 && streak >= 3) {
      warnings.add('Stagnation risk: no recent PRs despite high consistency. Try high intensity variation.');
      intensity = 'High';
    }

    if (missedSessions > 4) {
      warnings.add('Frequent session gaps ($missedSessions). Maintain base volume to build habits.');
      intensity = 'Normal';
    }

    return AdaptationOutput(
      recommendedIntensity: intensity,
      suggestRestDay: restDay,
      warningSignals: warnings,
    );
  }
}

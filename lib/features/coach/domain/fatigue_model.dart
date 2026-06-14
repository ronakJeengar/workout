enum FatigueState { low, moderate, high, overtrained }

class FatigueModel {
  final double fatigueScore; // 0.0 - 1.0
  final FatigueState recoveryState;
  final List<String> contributingFactors;

  const FatigueModel({
    required this.fatigueScore,
    required this.recoveryState,
    required this.contributingFactors,
  });
}

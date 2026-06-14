class ProgressInsight {
  final double volumeTrend;
  final double strengthTrend;
  final double consistencyScore;
  final bool plateauDetected;

  const ProgressInsight({
    required this.volumeTrend,
    required this.strengthTrend,
    required this.consistencyScore,
    required this.plateauDetected,
  });
}

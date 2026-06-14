class ProgressOverview {
  final int totalSessions;
  final double totalVolume;
  final Duration totalDuration;
  final int currentStreak;
  final int longestStreak;
  final double weeklyVolume;
  final double monthlyVolume;
  final int workoutsThisWeek;

  const ProgressOverview({
    required this.totalSessions,
    required this.totalVolume,
    required this.totalDuration,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyVolume,
    required this.monthlyVolume,
    required this.workoutsThisWeek,
  });
}

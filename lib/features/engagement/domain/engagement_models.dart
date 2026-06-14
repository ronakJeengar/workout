class EngagementStats {
  final int xp;
  final int level;
  final List<String> unlockedChallenges;

  EngagementStats({
    required this.xp,
    required this.level,
    required this.unlockedChallenges,
  });

  static EngagementStats calculate(int totalSets, int totalSessions) {
    // 10 XP per set, 100 XP per session
    final xp = (totalSets * 10) + (totalSessions * 100);
    // Level = floor(sqrt(XP / 100)) + 1
    final level = (xp / 500).floor() + 1;
    return EngagementStats(xp: xp, level: level, unlockedChallenges: []);
  }
}

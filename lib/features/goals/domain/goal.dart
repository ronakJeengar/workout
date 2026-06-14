enum GoalType { workoutsPerWeek, volumeTarget, streakTarget, sessionTarget }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  final double target;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    this.progress = 0,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null || progress >= target;

  Goal copyWith({
    String? title,
    GoalType? type,
    double? target,
    double? progress,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'target': target,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      type: GoalType.values[json['type'] as int],
      target: (json['target'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int iconData; // IconData.codePoint
  final DateTime? unlockedAt;
  final String tier; // bronze, silver, gold, elite
  final bool isHidden;
  final bool isSeasonal;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    this.unlockedAt,
    this.tier = 'bronze',
    this.isHidden = false,
    this.isSeasonal = false,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({
    DateTime? unlockedAt,
    String? tier,
    bool? isHidden,
    bool? isSeasonal,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconData: iconData,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      tier: tier ?? this.tier,
      isHidden: isHidden ?? this.isHidden,
      isSeasonal: isSeasonal ?? this.isSeasonal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconData': iconData,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'tier': tier,
      'isHidden': isHidden,
      'isSeasonal': isSeasonal,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconData: json['iconData'] as int,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
      tier: json['tier'] as String? ?? 'bronze',
      isHidden: json['isHidden'] as bool? ?? false,
      isSeasonal: json['isSeasonal'] as bool? ?? false,
    );
  }
}

class GoalProgress {
  final double current;
  final double target;
  
  const GoalProgress({required this.current, required this.target});
  
  double get percent => (current / target).clamp(0.0, 1.0);
}

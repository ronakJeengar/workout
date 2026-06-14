enum ActivityLevel { sedentary, light, moderate, active, elite }

class UserProfile {
  final String name;
  final double heightCm;
  final double weightKg;
  final int trainingAgeYears;
  final ActivityLevel activityLevel;
  final DateTime updatedAt;

  const UserProfile({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.trainingAgeYears,
    required this.activityLevel,
    required this.updatedAt,
  });

  String get trainingLevel {
    if (trainingAgeYears < 1) return 'NOVICE';
    if (trainingAgeYears < 3) return 'INTERMEDIATE';
    if (trainingAgeYears < 5) return 'ADVANCED';
    return 'ELITE';
  }

  // Simplified Mifflin-St Jeor Equation for BMR * Activity Multiplier
  double get estimatedTDEE {
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * 25) + 5; // Assumes age 25 male default for MVP
    double multiplier = 1.2;
    switch (activityLevel) {
      case ActivityLevel.sedentary: multiplier = 1.2; break;
      case ActivityLevel.light: multiplier = 1.375; break;
      case ActivityLevel.moderate: multiplier = 1.55; break;
      case ActivityLevel.active: multiplier = 1.725; break;
      case ActivityLevel.elite: multiplier = 1.9; break;
    }
    return bmr * multiplier;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'trainingAgeYears': trainingAgeYears,
      'activityLevel': activityLevel.index,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      trainingAgeYears: json['trainingAgeYears'] as int,
      activityLevel: ActivityLevel.values[json['activityLevel'] as int],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'TRAINER',
      heightCm: 175,
      weightKg: 75,
      trainingAgeYears: 0,
      activityLevel: ActivityLevel.moderate,
      updatedAt: DateTime.now(),
    );
  }
}

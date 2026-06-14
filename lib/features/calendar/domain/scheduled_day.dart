enum DayType { workout, rest, missed }

class ScheduledDay {
  final DateTime date;
  final String? workoutId;
  final String? programId;
  final String? note;
  final bool isRestDay;

  const ScheduledDay({
    required this.date,
    this.workoutId,
    this.programId,
    this.note,
    this.isRestDay = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workoutId': workoutId,
      'programId': programId,
      'note': note,
      'isRestDay': isRestDay,
    };
  }

  factory ScheduledDay.fromJson(Map<String, dynamic> json) {
    return ScheduledDay(
      date: DateTime.parse(json['date'] as String),
      workoutId: json['workoutId'] as String?,
      programId: json['programId'] as String?,
      note: json['note'] as String?,
      isRestDay: json['isRestDay'] as bool? ?? false,
    );
  }
}

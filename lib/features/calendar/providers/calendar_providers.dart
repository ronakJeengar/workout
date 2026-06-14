import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/scheduled_day.dart';
import '../data/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  throw UnimplementedError();
});

class CalendarNotifier extends AsyncNotifier<List<ScheduledDay>> {
  @override
  Future<List<ScheduledDay>> build() async {
    return ref.read(calendarRepositoryProvider).getSchedule();
  }

  Future<void> scheduleWorkout(DateTime date, String workoutId) async {
    final day = ScheduledDay(date: date, workoutId: workoutId);
    await ref.read(calendarRepositoryProvider).saveScheduledDay(day);
    ref.invalidateSelf();
  }

  Future<void> setRestDay(DateTime date) async {
    final day = ScheduledDay(date: date, isRestDay: true);
    await ref.read(calendarRepositoryProvider).saveScheduledDay(day);
    ref.invalidateSelf();
  }
}

final calendarProvider = AsyncNotifierProvider<CalendarNotifier, List<ScheduledDay>>(() {
  return CalendarNotifier();
});

final calendarActivityProvider = Provider<AsyncValue<Map<DateTime, bool>>>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.whenData((history) {
    final Map<DateTime, bool> activity = {};
    for (final session in history) {
      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      activity[date] = true;
    }
    return activity;
  });
});

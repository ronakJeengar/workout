import '../domain/scheduled_day.dart';

abstract class CalendarRepository {
  Future<List<ScheduledDay>> getSchedule();
  Future<void> saveScheduledDay(ScheduledDay day);
  Future<void> deleteScheduledDay(DateTime date);
}

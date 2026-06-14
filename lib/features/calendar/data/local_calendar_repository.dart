import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/scheduled_day.dart';
import 'calendar_repository.dart';

class LocalCalendarRepository implements CalendarRepository {
  static const String _calendarKey = 'calendar_v1';
  final SharedPreferences _prefs;

  LocalCalendarRepository(this._prefs);

  @override
  Future<List<ScheduledDay>> getSchedule() async {
    try {
      final String? data = _prefs.getString(_calendarKey);
      if (data == null) return [];
      final List decoded = jsonDecode(data);
      return decoded.map((item) => ScheduledDay.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveScheduledDay(ScheduledDay day) async {
    final schedule = await getSchedule();
    final dayOnly = DateTime(day.date.year, day.date.month, day.date.day);
    final index = schedule.indexWhere((d) {
      final sd = DateTime(d.date.year, d.date.month, d.date.day);
      return sd.isAtSameMomentAs(dayOnly);
    });

    if (index != -1) {
      schedule[index] = day;
    } else {
      schedule.add(day);
    }
    await _prefs.setString(_calendarKey, jsonEncode(schedule.map((d) => d.toJson()).toList()));
  }

  @override
  Future<void> deleteScheduledDay(DateTime date) async {
    final schedule = await getSchedule();
    final dayOnly = DateTime(date.year, date.month, date.day);
    schedule.removeWhere((d) {
      final sd = DateTime(d.date.year, d.date.month, d.date.day);
      return sd.isAtSameMomentAs(dayOnly);
    });
    await _prefs.setString(_calendarKey, jsonEncode(schedule.map((d) => d.toJson()).toList()));
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final crashTriageServiceProvider = Provider<CrashTriageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CrashTriageService(prefs);
});

class CrashReport {
  final String id;
  final DateTime timestamp;
  final String error;
  final String stackTrace;
  final String? reason;
  final String category;
  final String severity;

  const CrashReport({
    required this.id,
    required this.timestamp,
    required this.error,
    required this.stackTrace,
    this.reason,
    required this.category,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
        'stackTrace': stackTrace,
        'reason': reason,
        'category': category,
        'severity': severity,
      };

  factory CrashReport.fromJson(Map<String, dynamic> json) => CrashReport(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        error: json['error'] as String,
        stackTrace: json['stackTrace'] as String,
        reason: json['reason'] as String?,
        category: json['category'] as String,
        severity: json['severity'] as String,
      );
}

class CrashTriageService {
  static const String _storageKey = 'crash_reports_v1';
  final SharedPreferences _prefs;

  CrashTriageService(this._prefs);

  static String categorizeError(String error) {
    final err = error.toLowerCase();
    if (err.contains('migration') || err.contains('schema') || err.contains('isar') || err.contains('drift')) {
      return 'Database Migration Failure';
    } else if (err.contains('session') || err.contains('activesession') || err.contains('workoutsession') || err.contains('endsession')) {
      return 'Workout Session Life Cycle';
    } else if (err.contains('render') || err.contains('flex') || err.contains('overflow') || err.contains('layout') || err.contains('paint') || err.contains('markneedsbuild')) {
      return 'UI Render/Layout Failure';
    } else if (err.contains('json') || err.contains('format') || err.contains('corrupt') || err.contains('type \'_internallinkedhashmap')) {
      return 'Data Parse/Serialization';
    } else if (err.contains('null') || err.contains('null check')) {
      return 'Null Safety Violation';
    }
    return 'Uncategorized/System Error';
  }

  static String determineSeverity(String category) {
    switch (category) {
      case 'Database Migration Failure':
        return 'CRITICAL';
      case 'Workout Session Life Cycle':
      case 'Data Parse/Serialization':
        return 'HIGH';
      case 'Null Safety Violation':
        return 'MEDIUM';
      case 'UI Render/Layout Failure':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  Future<List<CrashReport>> getReports() async {
    final data = _prefs.getStringList(_storageKey);
    if (data == null || data.isEmpty) {
      return _getSimulatedCrashes();
    }
    return data.map((item) => CrashReport.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
  }

  Future<void> reportCrash(String error, String stackTrace, {String? reason}) async {
    final category = categorizeError(error);
    final severity = determineSeverity(category);
    final report = CrashReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      reason: reason,
      category: category,
      severity: severity,
    );
    final reports = await getReports();
    reports.add(report);
    if (reports.length > 50) {
      reports.removeAt(0);
    }
    await _prefs.setStringList(_storageKey, reports.map((r) => jsonEncode(r.toJson())).toList());
  }

  Future<void> clearReports() async {
    await _prefs.remove(_storageKey);
  }

  List<CrashReport> _getSimulatedCrashes() {
    final now = DateTime.now();
    return [
      CrashReport(
        id: 'sim-1',
        timestamp: now.subtract(const Duration(hours: 1)),
        error: 'IsarError: Schema drift detected between version 1 and 2',
        stackTrace: 'db_helper.dart:45\nmain.dart:22',
        reason: 'Migration failed',
        category: 'Database Migration Failure',
        severity: 'CRITICAL',
      ),
      CrashReport(
        id: 'sim-2',
        timestamp: now.subtract(const Duration(hours: 2)),
        error: 'StateError: No active session found when calling endSession()',
        stackTrace: 'workout_providers.dart:98\nworkout_session_screen.dart:109',
        reason: 'Workout ending state conflict',
        category: 'Workout Session Life Cycle',
        severity: 'HIGH',
      ),
      CrashReport(
        id: 'sim-3',
        timestamp: now.subtract(const Duration(hours: 4)),
        error: 'A RenderFlex overflowed by 24 pixels on the right.',
        stackTrace: 'volume_chart.dart:82\nrender_object.dart:1043',
        reason: 'Graph width calculation overflow',
        category: 'UI Render/Layout Failure',
        severity: 'LOW',
      ),
      CrashReport(
        id: 'sim-4',
        timestamp: now.subtract(const Duration(hours: 6)),
        error: 'Null check operator used on a null value in workout_home_screen.dart',
        stackTrace: 'workout_home_screen.dart:66\nwidget_test.dart:15',
        reason: 'Profile name missing',
        category: 'Null Safety Violation',
        severity: 'MEDIUM',
      ),
      CrashReport(
        id: 'sim-5',
        timestamp: now.subtract(const Duration(hours: 8)),
        error: 'FormatException: Unexpected character at line 1',
        stackTrace: 'json_codec.dart:12\nlocal_storage_workout_repository.dart:58',
        reason: 'SharedPreferences data corrupted',
        category: 'Data Parse/Serialization',
        severity: 'HIGH',
      ),
    ];
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/monitoring/user_behavior_tracker.dart';

class BackupData {
  final Map<String, dynamic> workouts;
  final Map<String, dynamic> sessions;
  final Map<String, dynamic> programs;
  final Map<String, dynamic> profile;

  BackupData({
    required this.workouts,
    required this.sessions,
    required this.programs,
    required this.profile,
  });

  String export() {
    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'payload': {
        'workouts': workouts,
        'sessions': sessions,
        'programs': programs,
        'profile': profile,
      },
    });
  }
}

final backupProvider = Provider((ref) {
  return BackupNotifier(ref);
});

class BackupNotifier {
  final Ref _ref;
  BackupNotifier(this._ref);

  Future<String> generateBackup() async {
    _ref.read(userBehaviorTrackerProvider).logEvent('export_usage');
    // Collect all data from repositories
    // For MVP implementation, we'll return a simple string representation
    return '{"status": "ready"}';
  }
}

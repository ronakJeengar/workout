import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crash_triage.dart';

final dataIntegrityServiceProvider = Provider<DataIntegrityService>((ref) {
  final crashTriage = ref.watch(crashTriageServiceProvider);
  return DataIntegrityService(crashTriage);
});

class DataIntegrityService {
  final CrashTriageService _crashTriage;

  DataIntegrityService(this._crashTriage);

  bool detectSchemaDrift(int savedVersion, int currentVersion, String key) {
    if (savedVersion != currentVersion) {
      _crashTriage.reportCrash(
        'Schema Drift Detected: Key "$key" has version $savedVersion, expected $currentVersion',
        StackTrace.current.toString(),
        reason: 'Migration required for key $key',
      );
      return true;
    }
    return false;
  }

  List<T> isolateCorruptedEntries<T>({
    required List<dynamic> rawData,
    required T Function(Map<String, dynamic>) fromJson,
    required String contextKey,
  }) {
    final parsed = <T>[];
    for (int i = 0; i < rawData.length; i++) {
      try {
        final itemMap = rawData[i] as Map<String, dynamic>;
        parsed.add(fromJson(itemMap));
      } catch (e, stack) {
        final msg = 'Corrupted Entry Isolated in "$contextKey" at index $i: $e';
        _crashTriage.reportCrash(
          msg,
          stack.toString(),
          reason: 'Data Integrity Recovery',
        );
        debugPrint('DATA_INTEGRITY: $msg');
      }
    }
    return parsed;
  }
}

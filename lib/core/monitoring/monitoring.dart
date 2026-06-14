import 'package:flutter/foundation.dart';

abstract class CrashReporter {
  void recordError(dynamic error, StackTrace? stack, {String? reason});
  void log(String message);
}

class DebugCrashReporter implements CrashReporter {
  @override
  void recordError(dynamic error, StackTrace? stack, {String? reason}) {
    if (kDebugMode) {
      print('CRASH_REPORT: $error\n$stack\nReason: $reason');
    }
  }

  @override
  void log(String message) {
    if (kDebugMode) {
      print('APP_LOG: $message');
    }
  }
}

abstract class Analytics {
  void logEvent(String name, {Map<String, dynamic>? parameters});
  void setUserProperty(String name, String value);
}

class DebugAnalytics implements Analytics {
  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('ANALYTICS_EVENT: $name $parameters');
    }
  }

  @override
  void setUserProperty(String name, String value) {
    if (kDebugMode) {
      print('ANALYTICS_USER_PROPERTY: $name = $value');
    }
  }
}

class PerformanceTracker {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void start(String label) {
    _stopwatches[label] = Stopwatch()..start();
  }

  static void stop(String label) {
    final sw = _stopwatches.remove(label);
    if (sw != null) {
      sw.stop();
      if (kDebugMode) {
        print('PERFORMANCE: $label took ${sw.elapsedMilliseconds}ms');
      }
    }
  }
}

class AppConfig {
  static const String version = '1.0.0+1';
  static const bool isDebug = !bool.fromEnvironment('dart.vm.product');
  
  static void log(String message) {
    if (isDebug) {
      // ignore: avoid_print
      print('[WorkoutApp] $message');
    }
  }
}

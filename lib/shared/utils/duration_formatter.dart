class DurationFormatter {
  static String formatMinutes(Duration? duration) {
    if (duration == null) return '0m';
    return '${duration.inMinutes}m';
  }

  static String formatMinutesSeconds(Duration? duration) {
    if (duration == null) return '0m 0s';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

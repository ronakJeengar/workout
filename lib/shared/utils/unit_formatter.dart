class UnitFormatter {
  static String formatWeight(double weight, {String unit = 'kg'}) {
    // Remove trailing zeros if it's a whole number
    final weightStr = weight == weight.toInt() ? weight.toInt().toString() : weight.toString();
    return '$weightStr$unit';
  }
}

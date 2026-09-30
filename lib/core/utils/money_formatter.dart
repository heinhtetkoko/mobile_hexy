/// Formats monetary displays without changing currency text or decimal digits.
/// Call only for amounts, never quantities, identifiers, or percentages.
abstract final class MoneyFormatter {
  static final _amount = RegExp(r'\d[\d,]*(?:\.\d+)?');
  static final _groupBoundary = RegExp(r'(\d)(?=(\d{3})+$)');

  /// Preserves the existing whole-number / two-decimal display convention.
  static String format(num value, {int? decimalDigits}) {
    final digits = decimalDigits ?? (value == value.roundToDouble() ? 0 : 2);
    return display(value.toStringAsFixed(digits));
  }

  /// Adds grouping to API display text, retaining symbols, signs and precision.
  static String display(Object? value) {
    return (value?.toString() ?? '').replaceAllMapped(_amount, (match) {
      final parts = match.group(0)!.replaceAll(',', '').split('.');
      parts[0] = parts[0].replaceAllMapped(
        _groupBoundary,
        (boundary) => '${boundary.group(1)},',
      );
      return parts.join('.');
    });
  }
}

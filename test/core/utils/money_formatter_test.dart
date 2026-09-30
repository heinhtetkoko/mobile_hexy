import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/utils/money_formatter.dart';
import 'package:mobile_hexy/data/models/order.dart';

void main() {
  test('groups whole amounts and preserves decimal conventions', () {
    expect(MoneyFormatter.format(1000), '1,000');
    expect(MoneyFormatter.format(1250000), '1,250,000');
    expect(MoneyFormatter.format(-100000), '-100,000');
    expect(MoneyFormatter.format(0), '0');
    expect(MoneyFormatter.format(1234.5), '1,234.50');
    expect(MoneyFormatter.format(1234, decimalDigits: 2), '1,234.00');
    expect(MoneyFormatter.format(999.999), '1,000.00');
  });

  test('retains API currency text, signs and fractional precision', () {
    for (final entry in {
      'Ks 1250000.000': 'Ks 1,250,000.000',
      '−12345.50 MMK': '−12,345.50 MMK',
      '(12345.00) USD': '(12,345.00) USD',
      '1,250,000 Ks': '1,250,000 Ks',
      'Free': 'Free',
      '': '',
    }.entries) {
      expect(MoneyFormatter.display(entry.key), entry.value);
      expect(MoneyFormatter.display(entry.value), entry.value);
    }
    expect(MoneyFormatter.display(null), '');
  });

  test('order totals handle numeric and preformatted API values', () {
    for (final total in [
      1250000,
      '1250000 Ks',
      {'formatted': '1250000 Ks'},
    ]) {
      final order = OrderSummary.fromJson({
        'total': total,
        'currency': {'symbol': 'Ks'},
      });
      expect(order.total, '1,250,000 Ks');
    }
  });
}

enum OrderStatus { pending, processing, delivered, refunded, cancelled }

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.number,
    required this.status,
    required this.itemCount,
    required this.date,
    required this.total,
    required this.actions,
    this.reason,
  });
  final String id;
  final String number;
  final OrderStatus status;
  final int itemCount;
  final DateTime date;
  final String total;
  final List<String> actions;
  final String? reason;

  factory OrderSummary.fromJson(Map<dynamic, dynamic> json) {
    final rawActions = json['actions'];
    final status = parseOrderStatus(
      (json['status'] ?? json['state'] ?? json['status_label'])?.toString(),
    );
    return OrderSummary(
      id: (json['id'] ?? json['order_id'])?.toString() ?? '',
      number:
          (json['number'] ?? json['name'] ?? json['order_number'])
              ?.toString() ??
          '',
      status: status,
      itemCount: _int(
        json['item_count'] ?? json['items_count'] ?? json['line_count'],
      ),
      date:
          DateTime.tryParse(
            (json['date'] ?? json['order_date'] ?? json['date_order'])
                    ?.toString() ??
                '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      total: _money(
        json['formatted_total'] ??
            json['total_display'] ??
            json['grand_total'] ??
            json['amount_total'] ??
            json['total'],
        json['currency'],
      ),
      actions: rawActions is List
          ? rawActions
                .map(
                  (action) => action is Map
                      ? (action['label'] ?? action['name'])?.toString() ?? ''
                      : action.toString(),
                )
                .where((action) => action.isNotEmpty)
                .toList()
          : const ['View Details'],
      reason: (json['reason'] ?? json['cancel_reason'])?.toString(),
    );
  }

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
  static String _money(Object? value, Object? currency) {
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    if (value is Map) {
      final formatted = (value['formatted'] ?? value['display_value'])
          ?.toString();
      if (formatted?.isNotEmpty == true) {
        return _moveSymbolAfterAmount(formatted!, symbol);
      }
      value = value['amount'] ?? value['value'];
    }
    if (value is num) return '${_number(value)} $symbol'.trim();
    return value?.toString() ?? '';
  }

  static String _moveSymbolAfterAmount(String value, String symbol) {
    if (symbol.isEmpty) return value;
    final amount = value.replaceAll(symbol, '').trim();
    return '$amount $symbol'.trim();
  }

  static String _number(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

OrderStatus parseOrderStatus(String? value) {
  final status = value?.toLowerCase() ?? '';
  if (status.contains('cancel')) return OrderStatus.cancelled;
  if (status.contains('refund') || status.contains('return')) {
    return OrderStatus.refunded;
  }
  if (status.contains('deliver') || status == 'done') {
    return OrderStatus.delivered;
  }
  if (status.contains('process') ||
      status.contains('confirm') ||
      status == 'sale') {
    return OrderStatus.processing;
  }
  return OrderStatus.pending;
}

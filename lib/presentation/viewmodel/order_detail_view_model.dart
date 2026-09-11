import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/orders_remote_data_source.dart';

class OrderDetailViewModel extends BaseViewModel {
  OrderDetailViewModel(this._remoteDataSource);
  final OrdersRemoteDataSource _remoteDataSource;
  final detail = <String, dynamic>{}.obs;
  final isLoading = true.obs;

  String get orderId {
    final args = Get.arguments;
    return args is Map ? args['id']?.toString() ?? '' : args?.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (orderId.isEmpty) {
      errorMessage.value = 'Order information is incomplete.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      detail.assignAll(await _remoteDataSource.fetchOrderDetail(orderId));
    } catch (error) {
      errorMessage.value = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('FormatException: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  String text(List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = detail[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  List<Map<String, dynamic>> get items {
    final source = detail['order_items'] ?? detail['items'] ?? detail['lines'];
    final raw = source is Map
        ? source['data'] ?? source['items'] ?? source['lines']
        : source;
    return raw is List
        ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : const [];
  }

  Map<dynamic, dynamic> get address {
    final value =
        detail['shipping_address'] ??
        detail['delivery_address'] ??
        _nestedValue(const ['delivery_information', 'address']) ??
        _nestedValue(const ['delivery', 'address']);
    return value is Map ? value : const {};
  }

  String get deliveryMethod => _detailText(
    const [
      'delivery_method',
      'delivery_method_name',
      'shipping_method',
      'shipping_method_name',
      'carrier',
      'carrier_name',
      'method',
      'method_name',
      'delivery_method_id',
      'carrier_id',
    ],
    containers: const ['delivery_information', 'delivery', 'shipping'],
  );

  String get paymentMethod => _detailText(
    const [
      'payment_method',
      'payment_method_name',
      'payment_provider',
      'payment_provider_name',
      'provider',
      'method',
      'method_name',
      'payment_method_code',
      'payment_code',
      'payment_method_id',
    ],
    containers: const ['payment_information', 'payment', 'transaction'],
  );

  String get deliveryNotes => _detailText(
    const [
      'delivery_notes',
      'delivery_note',
      'shipping_notes',
      'shipping_note',
      'customer_note',
      'note',
      'notes',
    ],
    containers: const ['delivery_information', 'delivery', 'shipping'],
  );

  String _detailText(List<String> keys, {List<String> containers = const []}) {
    for (final key in keys) {
      final result = _displayText(detail[key]);
      if (result.isNotEmpty) return result;
    }
    for (final containerKey in containers) {
      final container = detail[containerKey];
      if (container is! Map) continue;
      for (final key in keys) {
        final result = _displayText(container[key]);
        if (result.isNotEmpty) return result;
      }
    }
    return '';
  }

  Object? _nestedValue(List<String> path) {
    Object? value = detail;
    for (final key in path) {
      if (value is! Map) return null;
      value = value[key];
    }
    return value;
  }

  String _displayText(Object? value) {
    if (value is Map) {
      for (final key in const [
        'display_name',
        'label',
        'name',
        'title',
        'value',
        'code',
      ]) {
        final result = _displayText(value[key]);
        if (result.isNotEmpty) return result;
      }
      return '';
    }
    if (value is List) {
      return value
          .map(_displayText)
          .where((text) => text.isNotEmpty)
          .join(', ');
    }
    final result = value?.toString().trim() ?? '';
    return result == 'false' || result == 'null' ? '' : result;
  }

  List<Map<String, dynamic>> get summaryRows {
    final source =
        detail['order_summary'] ?? detail['summary'] ?? detail['totals'];
    final raw = source is Map
        ? source['rows'] ?? source['items'] ?? source['lines'] ?? source['data']
        : source;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(_normalizeSummaryRow)
          .where((row) => row['value']?.toString().isNotEmpty == true)
          .toList(growable: false);
    }
    final flatSource = raw is Map ? raw : source;
    if (flatSource is Map) {
      return flatSource.entries
          .where(
            (entry) => !const {
              'currency',
              'currency_symbol',
              'rows',
              'items',
              'lines',
              'data',
            }.contains(entry.key.toString()),
          )
          .map(
            (entry) =>
                _normalizeSummaryRow({'key': entry.key, 'value': entry.value}),
          )
          .where((row) => row['value']?.toString().isNotEmpty == true)
          .toList(growable: false);
    }

    final rows = <Map<String, dynamic>>[];
    _addSummaryRow(rows, 'Subtotal', const [
      'formatted_subtotal',
      'subtotal',
      'amount_untaxed',
    ]);
    _addSummaryRow(rows, 'Discount', const [
      'formatted_discount',
      'discount',
      'discount_amount',
      'coupon_discount',
    ]);
    _addSummaryRow(rows, 'Delivery Fee', const [
      'formatted_shipping',
      'shipping',
      'shipping_fee',
      'delivery_fee',
      'delivery_amount',
    ]);
    _addSummaryRow(rows, 'Tax', const [
      'formatted_tax',
      'tax',
      'tax_amount',
      'amount_tax',
    ]);
    _addSummaryRow(rows, 'Grand Total', const [
      'formatted_total',
      'grand_total',
      'amount_total',
      'total',
    ], isTotal: true);
    return rows;
  }

  void _addSummaryRow(
    List<Map<String, dynamic>> rows,
    String label,
    List<String> keys, {
    bool isTotal = false,
  }) {
    for (final key in keys) {
      final value = detail[key];
      if (_displayText(value).isEmpty) continue;
      rows.add({
        'key': key,
        'label': label,
        'value': _summaryValue(value),
        'is_total': isTotal,
      });
      return;
    }
  }

  Map<String, dynamic> _normalizeSummaryRow(Map<dynamic, dynamic> row) {
    final key =
        (row['key'] ?? row['code'] ?? row['name'] ?? row['label'])
            ?.toString() ??
        '';
    final rawValue =
        row['formatted_value'] ??
        row['formatted_amount'] ??
        row['display_value'] ??
        row['amount'] ??
        row['value'] ??
        row['price'];
    return {
      'key': key,
      'label': (row['label'] ?? row['title'])?.toString() ?? _summaryLabel(key),
      'value': _summaryValue(rawValue),
      'is_total':
          row['is_total'] == true ||
          row['total'] == true ||
          const {'grand_total', 'amount_total', 'total'}.contains(key),
    };
  }

  String _summaryValue(Object? value) {
    if (value is Map) {
      return _summaryValue(
        value['formatted_value'] ??
            value['formatted_amount'] ??
            value['display_value'] ??
            value['amount'] ??
            value['value'] ??
            value['price'],
      );
    }
    final text = _displayText(value);
    if (text.isEmpty) return '';
    final amount = double.tryParse(text.replaceAll(',', ''));
    if (amount == null || currencySymbol.isEmpty) return text;
    final formatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$formatted $currencySymbol';
  }

  String get currencySymbol {
    final currency =
        detail['currency'] ??
        (detail['order_summary'] is Map
            ? (detail['order_summary'] as Map)['currency']
            : null) ??
        (detail['totals'] is Map
            ? (detail['totals'] as Map)['currency']
            : null);
    if (currency is Map) {
      return (currency['symbol'] ?? currency['currency_symbol'])?.toString() ??
          '';
    }
    return (detail['currency_symbol'] ?? currency)?.toString() ?? '';
  }

  String _summaryLabel(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

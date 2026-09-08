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
    final raw = source is Map ? source['rows'] ?? source['data'] : source;
    return raw is List
        ? raw
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList()
        : const [];
  }
}

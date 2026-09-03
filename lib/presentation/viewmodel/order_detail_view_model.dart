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
    final value = detail['shipping_address'] ?? detail['delivery_information'];
    return value is Map ? value : const {};
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

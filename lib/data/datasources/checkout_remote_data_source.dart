import 'package:mobile_hexy/data/models/checkout_payment_provider.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class CheckoutRemoteDataSource {
  CheckoutRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchCheckout({String? orderId}) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.checkout,
      queryParameters: {
        'expanded': true,
        if (orderId != null) 'order_id': _numericId(orderId),
      },
    );
    final data = _checkoutPayload(response.data);
    if (orderId != null) {
      final order = data['order'];
      final returnedId =
          data['order_id'] ?? (order is Map ? order['id'] : null) ?? data['id'];
      if (returnedId?.toString() != orderId) {
        throw const FormatException(
          'Checkout could not load the selected pending order.',
        );
      }
    }
    return data;
  }

  Future<CheckoutPaymentProviders> fetchPaymentProviders() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.paymentProviders,
    );
    final data = _data(response.data);
    if (data is! Map || data['data'] is! List) {
      throw const FormatException('Payment methods are unavailable.');
    }
    final selected = data['selected'];
    return CheckoutPaymentProviders(
      items: (data['data'] as List)
          .whereType<Map>()
          .map(CheckoutPaymentProvider.fromJson)
          .where(
            (item) =>
                item.key.isNotEmpty &&
                item.code.isNotEmpty &&
                item.label.isNotEmpty,
          )
          .toList(),
      selectedKey: selected is Map
          ? (selected['key'] ?? selected['code'])?.toString()
          : null,
    );
  }

  Future<Map<String, dynamic>> placeOrder({
    String? orderId,
    required int shippingAddressId,
    required Object deliveryMethodId,
    required String paymentMethod,
    int? paymentMethodId,
    required bool termsAccepted,
    required String deliveryNotes,
  }) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.checkoutPlaceOrder,
      data: {
        if (orderId != null) 'order_id': _numericId(orderId),
        'shipping_address_id': shippingAddressId,
        'delivery_method_id': _numericId(deliveryMethodId),
        'payment_method_id': paymentMethodId,
        'payment_method': paymentMethod,
        'terms_accepted': termsAccepted,
        'delivery_notes': deliveryNotes,
      },
    );
    final data = _data(response.data);
    if (data is! Map) {
      throw const FormatException('The order could not be confirmed.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> fetchPaymentStatus(
    Map<String, dynamic> orderDetails,
  ) async {
    final statusUrl = orderDetails['status_url']?.toString().trim();
    final transactionId = orderDetails['transaction_id']?.toString();
    final statusPath = statusUrl == null || statusUrl.isEmpty
        ? '/api/v1/payments/$transactionId/status'
        : statusUrl;
    // Keep the authenticated request on the configured backend and bind it
    // to the transaction returned by place-order.
    final match = RegExp(
      r'^/?api/v1/payments/([1-9][0-9]*)/status$',
    ).firstMatch(statusPath);
    final id = match?.group(1);
    if (id == null || (transactionId != null && transactionId != id)) {
      throw const FormatException('Invalid payment status URL.');
    }

    final response = await _apiService.get<dynamic>(
      'api/v1/payments/$id/status',
    );
    final data = _data(response.data);
    final expectedOrderId = orderDetails['order_id']?.toString();
    if (data is! Map ||
        (data['transaction_id'] != null &&
            data['transaction_id'].toString() != id) ||
        (expectedOrderId != null &&
            data['order_id'] != null &&
            data['order_id'].toString() != expectedOrderId)) {
      throw const FormatException('Invalid payment status response.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchDeliveryMethods({
    String? orderId,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.deliveryMethods,
      queryParameters: orderId == null
          ? null
          : {'order_id': _numericId(orderId)},
    );
    final data = _data(response.data);
    final raw = data is List
        ? data
        : data is Map
        ? data['data'] ??
              data['delivery_methods'] ??
              data['methods'] ??
              data['carriers'] ??
              data['items']
        : null;
    return raw is List
        ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : const [];
  }

  Map<String, dynamic> _checkoutPayload(Object? body) {
    final data = _data(body);
    if (data is! Map) {
      throw const FormatException('Checkout data is unavailable.');
    }
    final nested = data['checkout'] ?? data['checkout_detail'];
    return Map<String, dynamic>.from(nested is Map ? nested : data);
  }

  Object? _data(Object? body) {
    if (body is Map && body['success'] == false) {
      throw FormatException(
        body['message']?.toString() ?? 'Checkout request failed.',
      );
    }
    return body is Map && body.containsKey('data') ? body['data'] : body;
  }

  Object _numericId(Object value) {
    final text = value.toString();
    return int.tryParse(text) ?? text;
  }
}

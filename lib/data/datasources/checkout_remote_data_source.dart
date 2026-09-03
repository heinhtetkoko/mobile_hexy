import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class CheckoutRemoteDataSource {
  CheckoutRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchCheckout() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.checkout,
      queryParameters: const {'expanded': true},
    );
    return _checkoutPayload(response.data);
  }

  Future<Map<String, dynamic>> updateCheckout({
    int? shippingAddressId,
    Object? deliveryMethodId,
    String? paymentMethod,
    String? deliveryNotes,
  }) async {
    final body = <String, dynamic>{};
    if (shippingAddressId != null) {
      body['shipping_address_id'] = shippingAddressId;
    }
    if (deliveryMethodId != null) {
      body['delivery_method_id'] = _numericId(deliveryMethodId);
    }
    if (paymentMethod != null) body['payment_method'] = paymentMethod;
    if (deliveryNotes != null) body['delivery_notes'] = deliveryNotes;
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.checkout,
      data: body,
    );
    return _checkoutPayload(response.data);
  }

  Future<Map<String, dynamic>> placeOrder({
    required int shippingAddressId,
    required Object deliveryMethodId,
    required String paymentMethod,
    required bool termsAccepted,
    required String deliveryNotes,
  }) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.checkoutPlaceOrder,
      data: {
        'shipping_address_id': shippingAddressId,
        'delivery_method_id': _numericId(deliveryMethodId),
        'payment_method_id': null,
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

  Future<List<Map<String, dynamic>>> fetchDeliveryMethods() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.deliveryMethods,
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

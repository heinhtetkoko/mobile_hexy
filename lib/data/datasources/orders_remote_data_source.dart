import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._apiService);
  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchOrders({
    required String status,
    required String sort,
    required int page,
    int limit = 10,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.orders,
      queryParameters: {
        'status': status,
        'sort': sort,
        'page': page,
        'limit': limit,
      },
    );
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw FormatException(
        body['message']?.toString() ?? 'Orders are unavailable.',
      );
    }
    if (body is Map && body['data'] is List) {
      return {
        'data': body['data'],
        if (body['meta'] is Map) 'meta': body['meta'],
      };
    }
    if (body is Map && body['data'] is Map) {
      final data = Map<String, dynamic>.from(body['data'] as Map);
      if (body['meta'] is Map && !data.containsKey('meta')) {
        data['meta'] = body['meta'];
      }
      return data;
    }
    throw const FormatException('Orders are unavailable.');
  }

  Future<Map<String, dynamic>> fetchOrderDetail(Object orderId) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.orderDetail(orderId),
    );
    final data = _payload(response.data, 'Order detail is unavailable.');
    final nested = data['order'] ?? data['order_detail'];
    return Map<String, dynamic>.from(nested is Map ? nested : data);
  }

  Map<String, dynamic> _payload(Object? body, String fallback) {
    if (body is Map && body['success'] == false) {
      throw FormatException(body['message']?.toString() ?? fallback);
    }
    final raw = body is Map && body.containsKey('data') ? body['data'] : body;
    if (raw is! Map) throw FormatException(fallback);
    return Map<String, dynamic>.from(raw);
  }
}

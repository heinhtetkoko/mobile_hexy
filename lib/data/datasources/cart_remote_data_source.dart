import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._apiService);

  final ApiService _apiService;
  final badgeCount = 0.obs;

  Future<Map<String, dynamic>> fetchCart() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.cart);
    return _parseCartResponse(response.data);
  }

  Future<Map<String, dynamic>> addProduct({
    required int productId,
    required int quantity,
  }) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.cart,
      data: {'action': 'add', 'product_id': productId, 'quantity': quantity},
      options: Options(
        extra: const {ApiEndpoints.redirectOnUnauthorizedKey: true},
      ),
    );
    return _parseCartResponse(response.data);
  }

  Future<Map<String, dynamic>> updateQuantity({
    required int? lineId,
    required int productId,
    required int quantity,
  }) => _performAction({
    'action': 'update',
    if (lineId != null && lineId > 0) 'line_id': lineId,
    if (lineId != null && lineId > 0) 'cart_line_id': lineId,
    if (productId > 0) 'product_id': productId,
    'quantity': quantity,
  });

  Future<Map<String, dynamic>> removeLine(int lineId) => _performAction({
    'action': 'remove',
    'line_id': lineId,
    'cart_line_id': lineId,
  });

  Future<Map<String, dynamic>> applyCoupon(String code) =>
      _performAction({'action': 'apply_coupon', 'coupon_code': code});

  Future<Map<String, dynamic>> setShippingMethod(Object methodId) =>
      _performAction({
        'action': 'set_shipping_method',
        'shipping_method_id': methodId,
      });

  Future<Map<String, dynamic>> setShippingAddress(int addressId) =>
      _performAction({
        'action': 'set_shipping_address',
        'address_id': addressId,
      });

  Future<Map<String, dynamic>> _performAction(Map<String, dynamic> data) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.cart,
      data: data,
    );
    return _parseCartResponse(response.data);
  }

  Map<String, dynamic> _parseCartResponse(Object? body) {
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      final message = body is Map ? body['message']?.toString() : null;
      throw FormatException(message ?? 'Could not update shopping cart.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final cart = data['cart'] ?? data['cart_screen'];
    final payload = cart is Map ? Map<String, dynamic>.from(cart) : data;
    updateBadge(payload);
    return payload;
  }

  void updateBadge(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['cart_items'] ?? data['lines'];
    final fallbackCount = rawItems is List
        ? rawItems.fold<int>(0, (total, item) {
            if (item is! Map) return total;
            return total +
                (_asInt(
                      item['quantity'] ??
                          item['qty'] ??
                          item['cart_qty'] ??
                          item['product_uom_qty'] ??
                          item['ordered_qty'],
                    ) ??
                    1);
          })
        : 0;
    final summary = data['summary'] is Map ? data['summary'] as Map : const {};
    final meta = data['meta'] is Map ? data['meta'] as Map : const {};
    final badges = data['badge_counts'] is Map
        ? data['badge_counts'] as Map
        : data['badges'] is Map
        ? data['badges'] as Map
        : const {};
    badgeCount.value =
        _firstInt([
          data['badge_count'],
          data['item_count'],
          data['cart_count'],
          data['total_quantity'],
          data['total_qty'],
          summary['badge_count'],
          summary['item_count'],
          summary['total_quantity'],
          summary['total_qty'],
          meta['badge_count'],
          meta['item_count'],
          badges['cart'],
          badges['cart_count'],
        ]) ??
        fallbackCount;
  }

  int? _firstInt(List<Object?> values) {
    for (final value in values) {
      final parsed = _asInt(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _asInt(Object? value) {
    if (value is num) return value.toInt();
    final text = value?.toString().trim() ?? '';
    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
}

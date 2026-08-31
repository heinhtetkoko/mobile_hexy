import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/wishlist_item.dart';

class WishlistResult {
  const WishlistResult({required this.items, required this.badgeCount});

  final List<WishlistItem> items;
  final int badgeCount;
}

class WishlistRemoteDataSource {
  WishlistRemoteDataSource(this._apiService);

  final ApiService _apiService;
  final badgeCount = 0.obs;

  Future<WishlistResult> fetchWishlist() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.wishlist);
    return _parseResponse(response.data);
  }

  Future<WishlistResult> remove({
    required String wishlistId,
    required int productId,
  }) => _performAction({
    'action': 'remove',
    if (int.tryParse(wishlistId) case final int id) 'wishlist_id': id,
    if (int.tryParse(wishlistId) == null) 'product_id': productId,
  });

  Future<WishlistResult> toggle(int productId) =>
      _performAction({'action': 'toggle', 'product_id': productId});

  Future<WishlistResult> moveToCart(int productId) => _performAction({
    'action': 'move_to_cart',
    'product_id': productId,
    'quantity': 1,
    'remove_from_wishlist': true,
  });

  Future<WishlistResult> clear() => _performAction({'action': 'clear'});

  Future<WishlistResult> _performAction(Map<String, dynamic> data) async {
    final response = await _apiService.post<dynamic>(
      ApiEndpoints.wishlist,
      data: data,
      options: Options(
        extra: const {ApiEndpoints.redirectOnUnauthorizedKey: true},
      ),
    );
    return _parseResponse(response.data);
  }

  WishlistResult _parseResponse(Object? body) {
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      final message = body is Map ? body['message']?.toString() : null;
      throw FormatException(message ?? 'Could not update wishlist.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final rawItems =
        data['items'] ?? data['wishlist_items'] ?? data['products'];
    final items = rawItems is List
        ? rawItems.whereType<Map>().map(_parseItem).toList(growable: false)
        : const <WishlistItem>[];
    final count =
        int.tryParse(
          (data['badge_count'] ?? data['count'] ?? data['item_count'])
                  ?.toString() ??
              '',
        ) ??
        items.length;
    badgeCount.value = count;
    return WishlistResult(items: items, badgeCount: count);
  }

  WishlistItem _parseItem(Map<dynamic, dynamic> json) {
    final product = json['product'];
    final source = product is Map ? {...json, ...product} : json;
    final currency = source['currency'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price =
        double.tryParse(
          (source['current_price'] ?? source['sale_price'] ?? source['price'])
                  ?.toString() ??
              '',
        ) ??
        0;
    final amount = price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
    return WishlistItem(
      id: (json['wishlist_id'] ?? json['id'])?.toString() ?? '',
      productId:
          int.tryParse(
            (source['product_id'] ?? source['id'])?.toString() ?? '',
          ) ??
          0,
      name: source['name']?.toString() ?? '',
      price: '$amount $symbol'.trim(),
      imageAsset: '',
      imageUrl:
          (source['image_url'] ?? source['image'] ?? source['thumbnail_url'])
              ?.toString(),
      inStock: source['in_stock'] != false,
      cartQuantity: int.tryParse(source['cart_qty']?.toString() ?? '') ?? 0,
    );
  }
}

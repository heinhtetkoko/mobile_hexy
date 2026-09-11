import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';

class HomeProductsResult {
  const HomeProductsResult({
    required this.products,
    required this.page,
    required this.hasNext,
  });

  final List<HomeProduct> products;
  final int page;
  final bool hasNext;
}

class HomeProductsRemoteDataSource {
  const HomeProductsRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<HomeProductsResult> fetch({
    required String path,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      path,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! List) {
      throw const FormatException('Could not load products.');
    }
    final products = (body['data'] as List)
        .whereType<Map>()
        .map(_parseProduct)
        .toList(growable: false);
    final meta = body['meta'];
    return HomeProductsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  HomeProduct _parseProduct(Map<dynamic, dynamic> json) {
    final currency = json['currency'];
    final discount = json['discount'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price =
        double.tryParse(
          (json['current_price'] ?? json['sale_price'] ?? json['price'])
                  ?.toString() ??
              '',
        ) ??
        0;
    final originalPrice = double.tryParse(
      (json['original_price'] ?? json['compare_at_price'] ?? json['list_price'])
              ?.toString() ??
          '',
    );
    final explicitDiscount = _parsePercent(
      json['discount_percentage'] ??
          json['discount_percent'] ??
          json['discount_value'] ??
          (discount is Map
              ? discount['percentage'] ??
                    discount['percent'] ??
                    discount['value']
              : discount),
    );
    final calculatedDiscount = originalPrice != null && originalPrice > price
        ? ((originalPrice - price) / originalPrice) * 100
        : null;
    return HomeProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: '${price.toStringAsFixed(2)} $symbol'.trim(),
      imageAsset: '',
      imageUrl: json['image_url']?.toString(),
      hot: json['in_stock'] == true,
      wishlist: json['wishlist'] == true,
      availableQty:
          double.tryParse(json['available_qty']?.toString() ?? '') ?? 0,
      discountPercent: explicitDiscount ?? calculatedDiscount,
      variantId: _parsePositiveInt(
        json['product_variant_id'] ?? json['variant_id'],
      ),
      countdownSeconds: _countdownSeconds(json),
    );
  }

  int? _countdownSeconds(Map<dynamic, dynamic> json) {
    final timer = json['flash_sale_timer'];
    final direct = _parseNonNegativeInt(
      json['countdown_seconds'] ??
          json['time_limit_count'] ??
          (timer is Map
              ? timer['countdown_seconds'] ??
                    timer['remaining_seconds'] ??
                    timer['seconds_remaining']
              : null),
    );
    if (direct != null) return direct;

    final rawEnd =
        json['sale_ends_at'] ??
        (timer is Map ? timer['sale_ends_at'] ?? timer['ends_at'] : null);
    final end = DateTime.tryParse(rawEnd?.toString() ?? '');
    if (end == null) return null;
    final remaining = end.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  int? _parseNonNegativeInt(Object? value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '');
    return parsed != null && parsed >= 0 ? parsed : null;
  }

  int? _parsePositiveInt(Object? value) {
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }

  double? _parsePercent(Object? value) {
    final parsed = double.tryParse(
      value?.toString().replaceAll('%', '').replaceAll('-', '').trim() ?? '',
    );
    return parsed == null || parsed <= 0 ? null : parsed;
  }
}

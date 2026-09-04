import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';

class NewArrivalsResult {
  const NewArrivalsResult({
    required this.products,
    required this.page,
    required this.hasNext,
  });

  final List<HomeProduct> products;
  final int page;
  final bool hasNext;
}

class NewArrivalsRemoteDataSource {
  const NewArrivalsRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<NewArrivalsResult> fetch({
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.newArrivals,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! List) {
      throw const FormatException('Could not load new arrivals.');
    }

    final products = (body['data'] as List)
        .whereType<Map>()
        .map(_parseProduct)
        .toList(growable: false);
    final meta = body['meta'];
    return NewArrivalsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  HomeProduct _parseProduct(Map<dynamic, dynamic> json) {
    final currency = json['currency'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price = double.tryParse(json['price']?.toString() ?? '') ?? 0;
    return HomeProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: '${price.toStringAsFixed(2)} $symbol'.trim(),
      imageAsset: '',
      imageUrl: json['image_url']?.toString(),
      hot: json['in_stock'] == true,
      discountPercent: _discountPercent(json),
    );
  }

  double? _discountPercent(Map<dynamic, dynamic> json) {
    final discount = json['discount'];
    final value =
        json['discount_percentage'] ??
        json['discount_percent'] ??
        json['discount_value'] ??
        (discount is Map
            ? discount['percentage'] ?? discount['percent'] ?? discount['value']
            : discount);
    final parsed = double.tryParse(
      value?.toString().replaceAll('%', '').replaceAll('-', '').trim() ?? '',
    );
    return parsed == null || parsed <= 0 ? null : parsed;
  }
}

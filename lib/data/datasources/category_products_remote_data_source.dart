import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/catalog_product.dart';

class CategoryProductsResult {
  const CategoryProductsResult({
    required this.products,
    required this.page,
    required this.hasNext,
  });

  final List<CatalogProduct> products;
  final int page;
  final bool hasNext;
}

class CategoryProductsRemoteDataSource {
  const CategoryProductsRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<CategoryProductsResult> fetchProducts({
    required int categoryId,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      'api/v1/categories/$categoryId/products',
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
    return CategoryProductsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  Future<CategoryProductsResult> searchProducts({
    required String query,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.productSearch,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! List) {
      throw const FormatException('Could not search products.');
    }
    final products = (body['data'] as List)
        .whereType<Map>()
        .map(_parseProduct)
        .toList(growable: false);
    final meta = body['meta'];
    return CategoryProductsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  Future<CategoryProductsResult> fetchAllProducts({
    required String query,
    required int? categoryId,
    required int? brandId,
    required double? minPrice,
    required double? maxPrice,
    required bool? inStock,
    required String sort,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.allProducts,
      queryParameters: {
        'q': query,
        'category_id': ?categoryId,
        'brand_id': ?brandId,
        'min_price': ?minPrice,
        'max_price': ?maxPrice,
        'in_stock': ?inStock,
        'sort': sort,
        'page': page,
        'limit': limit,
      },
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
    return CategoryProductsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  Future<CategoryProductsResult> fetchDiscountProducts({
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.discountProducts,
      queryParameters: {
        'source': 'all',
        'sort': 'highest_discount',
        'page': page,
        'limit': limit,
      },
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! List) {
      throw const FormatException('Could not load promotional products.');
    }
    final products = (body['data'] as List)
        .whereType<Map>()
        .map(_parseProduct)
        .toList(growable: false);
    final meta = body['meta'];
    return CategoryProductsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  CatalogProduct _parseProduct(Map<dynamic, dynamic> json) {
    final currency = json['currency'];
    final discountData = json['discount'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price =
        double.tryParse(
          (json['current_price'] ?? json['sale_price'] ?? json['price'])
                  ?.toString() ??
              '',
        ) ??
        0;
    final compareAt = double.tryParse(
      (json['original_price'] ?? json['list_price'] ?? json['compare_at_price'])
              ?.toString() ??
          '',
    );
    final explicitDiscount = _parsePercent(
      json['discount_percentage'] ??
          json['discount_percent'] ??
          json['discount_value'] ??
          (discountData is Map
              ? discountData['percentage'] ??
                    discountData['percent'] ??
                    discountData['value']
              : discountData),
    );
    final calculatedDiscount = compareAt != null && compareAt > price
        ? ((compareAt - price) / compareAt) * 100
        : 0.0;
    final discount = explicitDiscount > 0
        ? explicitDiscount
        : calculatedDiscount;
    return CatalogProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: '$symbol${price.toStringAsFixed(2)}',
      originalPrice: compareAt == null
          ? null
          : '$symbol${compareAt.toStringAsFixed(2)}',
      discount: discount > 0 ? '-${_formatPercent(discount)}%' : null,
      imageAsset: '',
      imageUrl: json['image_url']?.toString(),
    );
  }

  double _parsePercent(Object? value) =>
      double.tryParse(
        value?.toString().replaceAll('%', '').replaceAll('-', '').trim() ?? '',
      ) ??
      0;

  String _formatPercent(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}

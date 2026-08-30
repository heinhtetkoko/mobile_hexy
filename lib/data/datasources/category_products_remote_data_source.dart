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

  CatalogProduct _parseProduct(Map<dynamic, dynamic> json) {
    final currency = json['currency'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price = double.tryParse(json['price']?.toString() ?? '') ?? 0;
    final compareAt = double.tryParse(
      json['compare_at_price']?.toString() ?? '',
    );
    final discount =
        int.tryParse(json['discount_percent']?.toString() ?? '') ?? 0;
    return CatalogProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: '$symbol${price.toStringAsFixed(2)}',
      originalPrice: compareAt == null
          ? null
          : '$symbol${compareAt.toStringAsFixed(2)}',
      discount: discount > 0 ? '-$discount%' : null,
      imageAsset: '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/catalog_product.dart';
import 'package:mobile_hexy/data/models/product_collection.dart';

class CollectionDetailResult {
  const CollectionDetailResult({required this.name, required this.products});
  final String name;
  final List<CatalogProduct> products;
}

class CollectionsRemoteDataSource {
  const CollectionsRemoteDataSource(this._apiService);
  final ApiService _apiService;

  Future<List<ProductCollection>> fetchCollections() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.collections,
      queryParameters: const {'include_products': false, 'product_limit': 0},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not load collections.');
    }
    final data = body['data'];
    final raw = data is List
        ? data
        : data is Map
        ? data['collections'] ?? data['items'] ?? data['data']
        : null;
    return raw is List
        ? raw
              .whereType<Map>()
              .map(ProductCollection.fromJson)
              .where((item) => item.id > 0 && item.name.isNotEmpty)
              .toList()
        : const [];
  }

  Future<CollectionDetailResult> fetchCollection(int id) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.collection(id),
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false || body['data'] is! Map) {
      throw const FormatException('Could not load collection products.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final productSource =
        data['products'] ?? data['items'] ?? data['collection_products'];
    final raw = productSource is Map
        ? productSource['data'] ??
              productSource['items'] ??
              productSource['products']
        : productSource;
    return CollectionDetailResult(
      name:
          (data['name'] ?? data['title'] ?? data['display_name'])?.toString() ??
          '',
      products: raw is List
          ? raw.whereType<Map>().map(_parseProduct).toList()
          : const [],
    );
  }

  CatalogProduct _parseProduct(Map<dynamic, dynamic> json) {
    final product = json['product'];
    final source = product is Map ? {...json, ...product} : json;
    final currency = source['currency'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price = _number(
      source['current_price'] ?? source['sale_price'] ?? source['price'],
    );
    final original = _nullableNumber(
      source['original_price'] ?? source['list_price'],
    );
    final discount = _nullableNumber(
      source['discount_percentage'] ?? source['discount_percent'],
    );
    return CatalogProduct(
      id: (source['product_id'] ?? source['id'])?.toString() ?? '',
      name: source['name']?.toString() ?? '',
      price: '$symbol${_format(price)}',
      originalPrice: original == null ? null : '$symbol${_format(original)}',
      discount: discount == null || discount <= 0
          ? null
          : '-${_format(discount)}%',
      imageAsset: '',
      imageUrl:
          (source['image_url'] ?? source['image'] ?? source['thumbnail_url'])
              ?.toString(),
    );
  }

  double _number(Object? value) => _nullableNumber(value) ?? 0;
  double? _nullableNumber(Object? value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  String _format(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

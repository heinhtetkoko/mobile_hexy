import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/product_detail.dart';

class ProductDetailRemoteDataSource {
  const ProductDetailRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<ProductDetail> fetch(int id) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.productDetail(id),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      throw const FormatException('Could not load product details.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final currency = data['currency'];
    final categories = data['categories'];
    final variants = data['variants'];
    final gallery = data['gallery'];
    final imageUrls = <String>[
      if (data['image_url']?.toString().isNotEmpty == true)
        data['image_url'].toString(),
      if (gallery is List)
        ...gallery
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty),
    ];
    return ProductDetail(
      id: int.tryParse(data['id']?.toString() ?? '') ?? id,
      name: data['name']?.toString() ?? '',
      sku: data['sku'] == false ? '' : data['sku']?.toString() ?? '',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0,
      compareAtPrice: double.tryParse(
        data['compare_at_price']?.toString() ?? '',
      ),
      discountPercent:
          int.tryParse(data['discount_percent']?.toString() ?? '') ?? 0,
      currencySymbol: currency is Map
          ? currency['symbol']?.toString() ?? ''
          : '',
      imageUrls: imageUrls,
      rating: double.tryParse(data['rating']?.toString() ?? '') ?? 0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '') ?? 0,
      inStock: data['in_stock'] == true,
      availableQuantity:
          double.tryParse(data['available_qty']?.toString() ?? '') ?? 0,
      description: data['description']?.toString() ?? '',
      categories: categories is List
          ? categories
                .whereType<Map>()
                .map((value) => value['name']?.toString() ?? '')
                .where((value) => value.isNotEmpty)
                .toList(growable: false)
          : const [],
      variants: variants is List
          ? variants
                .whereType<Map>()
                .map((value) {
                  return ProductVariant(
                    id: int.tryParse(value['id']?.toString() ?? '') ?? 0,
                    name: value['name']?.toString() ?? '',
                    sku: value['sku'] == false
                        ? ''
                        : value['sku']?.toString() ?? '',
                    availableQuantity:
                        double.tryParse(
                          value['available_qty']?.toString() ?? '',
                        ) ??
                        0,
                  );
                })
                .toList(growable: false)
          : const [],
    );
  }
}

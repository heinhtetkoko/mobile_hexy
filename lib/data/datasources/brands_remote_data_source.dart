import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';

class BrandsRemoteDataSource {
  const BrandsRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<List<CatalogBrand>> fetchBrands() async {
    final response = await _apiService.get<dynamic>(ApiEndpoints.brands);
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw const FormatException('Could not load brands.');
    }

    final data = body['data'];
    final brands = data is List
        ? data
        : data is Map && data['brands'] is List
        ? data['brands'] as List
        : body['brands'];
    if (brands is! List) {
      throw const FormatException('Invalid brands response.');
    }

    return brands
        .whereType<Map>()
        .map((item) => CatalogBrand.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id > 0 && item.name.isNotEmpty)
        .toList(growable: false);
  }
}

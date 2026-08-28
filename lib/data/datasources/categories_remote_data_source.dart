import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';

class CategoriesRemoteDataSource {
  const CategoriesRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<List<CatalogCategory>> fetchCategories({String? path}) async {
    final response = await _apiService.get<dynamic>(
      path ?? ApiEndpoints.categories,
    );
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw const FormatException('Could not load categories.');
    }
    final data = body['data'];
    final categories = data is List
        ? data
        : data is Map && data['categories'] is List
        ? data['categories'] as List
        : body['categories'];
    if (categories is! List) {
      throw const FormatException('Invalid categories response.');
    }
    return categories
        .whereType<Map>()
        .map(
          (item) => CatalogCategory.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.id > 0 && item.name.isNotEmpty)
        .toList(growable: false);
  }
}

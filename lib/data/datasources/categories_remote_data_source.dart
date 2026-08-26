import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/constants/api_constants.dart';
import 'package:mobile_hexy/domain/entities/catalog_category.dart';

class CategoriesRemoteDataSource {
  const CategoriesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CatalogCategory>> fetchCategories({String? path}) async {
    final response = await _dio.get<dynamic>(
      path ?? ApiConstants.categories,
      options: Options(extra: {ApiConstants.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw const FormatException('Could not load categories.');
    }
    final data = body['data'];
    final categories = data is Map ? data['categories'] : null;
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

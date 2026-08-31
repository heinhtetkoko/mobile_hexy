import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';

class BannersRemoteDataSource {
  const BannersRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<List<HomeBanner>> fetchBanners() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.banners,
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false || body['data'] is! List) {
      throw const FormatException('Could not load banners.');
    }

    return (body['data'] as List)
        .whereType<Map>()
        .map((item) {
          final data = Map<String, dynamic>.from(item);
          final imageUrl =
              data['mobile_image_url']?.toString().trim() ??
              data['image_url']?.toString().trim() ??
              '';
          return HomeBanner(
            title: data['headline']?.toString() ?? '',
            subtitle: data['subtitle']?.toString() ?? '',
            imageUrl: imageUrl,
          );
        })
        .where((banner) => banner.imageUrl?.isNotEmpty == true)
        .toList(growable: false);
  }
}

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

  Future<List<HomePromoBanner>> fetchPromoBanners() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.promoBanners,
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not load promo banners.');
    }

    final rawData = body['data'];
    final items = rawData is List
        ? rawData
        : rawData is Map
        ? (rawData['items'] ?? rawData['banners'] ?? const [])
        : const [];
    if (items is! List) {
      throw const FormatException('Could not load promo banners.');
    }

    String value(Map<String, dynamic> data, List<String> keys) {
      for (final key in keys) {
        final result = data[key]?.toString().trim() ?? '';
        if (result.isNotEmpty) return result;
      }
      return '';
    }

    return items
        .whereType<Map>()
        .map((item) {
          final data = Map<String, dynamic>.from(item);
          final title = value(data, const ['headline', 'title', 'name']);
          final subtitle = value(data, const [
            'subtitle',
            'description',
            'body',
          ]);
          final buttonText = value(data, const [
            'button_text',
            'cta_text',
            'action_text',
          ]);
          final imageUrl = value(data, const [
            'mobile_image_url',
            'image_url',
            'banner_url',
          ]);
          return HomePromoBanner(
            title: title,
            subtitle: subtitle,
            buttonText: buttonText,
            imageUrl: imageUrl.isEmpty ? null : imageUrl,
          );
        })
        .where((banner) => banner.title.isNotEmpty)
        .toList(growable: false);
  }
}

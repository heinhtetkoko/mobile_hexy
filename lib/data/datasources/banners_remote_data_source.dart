import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';

class BannersRemoteDataSource {
  const BannersRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<String?> fetchPopupAdImage() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.popupAds,
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Could not load popup ads.');
    }

    final rawData = body['data'];
    final candidates = rawData is List
        ? rawData.whereType<Map>()
        : rawData is Map
        ? ((rawData['items'] ?? rawData['ads']) is List
              ? ((rawData['items'] ?? rawData['ads']) as List).whereType<Map>()
              : [rawData])
        : const <Map>[];

    for (final item in candidates) {
      if (item['active'] == false || item['is_active'] == false) continue;
      final url = _firstValue(item, const [
        'mobile_image_url',
        'popup_image_url',
        'image_url',
        'banner_url',
        'image',
      ]);
      if (url.isNotEmpty) {
        return Uri.parse(ApiEndpoints.baseUrl).resolve(url).toString();
      }
    }
    return null;
  }

  String _firstValue(Map<dynamic, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

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
            imageUrl: imageUrl.isEmpty
                ? null
                : Uri.parse(ApiEndpoints.baseUrl).resolve(imageUrl).toString(),
          );
        })
        .where((banner) => banner.imageUrl?.isNotEmpty == true)
        .toList(growable: false);
  }
}

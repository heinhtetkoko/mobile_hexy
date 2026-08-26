import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/constants/api_constants.dart';
import 'package:mobile_hexy/domain/entities/home_catalog.dart';

class NewArrivalsResult {
  const NewArrivalsResult({
    required this.products,
    required this.page,
    required this.hasNext,
  });

  final List<HomeProduct> products;
  final int page;
  final bool hasNext;
}

class NewArrivalsRemoteDataSource {
  const NewArrivalsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NewArrivalsResult> fetch({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.newArrivals,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(extra: {ApiConstants.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! List) {
      throw const FormatException('Could not load new arrivals.');
    }

    final products = (body['data'] as List)
        .whereType<Map>()
        .map(_parseProduct)
        .toList(growable: false);
    final meta = body['meta'];
    return NewArrivalsResult(
      products: products,
      page: meta is Map
          ? int.tryParse(meta['page']?.toString() ?? '') ?? page
          : page,
      hasNext: meta is Map && meta['has_next'] == true,
    );
  }

  HomeProduct _parseProduct(Map<dynamic, dynamic> json) {
    final currency = json['currency'];
    final symbol = currency is Map ? currency['symbol']?.toString() ?? '' : '';
    final price = double.tryParse(json['price']?.toString() ?? '') ?? 0;
    return HomeProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: '$symbol${price.toStringAsFixed(2)}',
      imageAsset: '',
      imageUrl: json['image_url']?.toString(),
      hot: json['in_stock'] == true,
    );
  }
}

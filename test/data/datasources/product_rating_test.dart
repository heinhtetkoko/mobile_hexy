import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';

void main() {
  test(
    'posts each star value using product ID and authenticated request',
    () async {
      final api = _Api();
      final source = ProductDetailRemoteDataSource(api);
      for (var rating = 1; rating <= 5; rating++) {
        await source.submitRating(22, rating);
        expect(api.path, 'api/v1/products/22/rating');
        expect(api.payload, {'rating': rating});
        expect(api.options?.extra?[ApiEndpoints.requiresAuthKey], true);
        expect(
          api.options?.extra?[ApiEndpoints.redirectOnUnauthorizedKey],
          true,
        );
      }
    },
  );
  test('rejects failed and malformed responses', () async {
    final api = _Api();
    final source = ProductDetailRemoteDataSource(api);
    for (final body in [
      null,
      {'success': false, 'message': 'Rejected'},
    ]) {
      api.body = body;
      await expectLater(
        source.submitRating(22, 4),
        throwsA(isA<ServerException>()),
      );
    }
  });
  test('invalid ratings do not send requests', () async {
    final api = _Api();
    final source = ProductDetailRemoteDataSource(api);
    for (final rating in [0, 6]) {
      await expectLater(source.submitRating(22, rating), throwsArgumentError);
    }
    expect(api.path, isNull);
  });
}

class _Api extends ApiService {
  _Api() : super(Dio());
  Object? body = {'success': true};
  String? path;
  Object? payload;
  Options? options;
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    this.path = path;
    payload = data;
    this.options = options;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: body as T?,
    );
  }
}

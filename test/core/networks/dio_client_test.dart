import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/dio_client.dart';

void main() {
  test('configures the shared HTTP defaults', () {
    final dio = DioClient.create(baseUrl: 'https://example.com');

    expect(dio.options.baseUrl, 'https://example.com');
    expect(dio.options.connectTimeout, ApiEndpoints.connectTimeout);
    expect(dio.options.receiveTimeout, ApiEndpoints.receiveTimeout);
    expect(dio.options.sendTimeout, ApiEndpoints.sendTimeout);
    expect(dio.options.headers['Accept'], 'application/json');
  });

  test('adds a bearer token when one is available', () async {
    final dio = DioClient.create(
      baseUrl: 'https://example.com',
      accessTokenProvider: () async => 'test-token',
    );
    final adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;
    await dio.get<void>('/products');

    expect(adapter.request?.headers['Authorization'], 'Bearer test-token');
  });

  test('does not read a token for public requests', () async {
    var tokenWasRead = false;
    final dio = DioClient.create(
      baseUrl: 'https://example.com',
      accessTokenProvider: () {
        tokenWasRead = true;
        return 'test-token';
      },
    );
    final adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;

    await dio.post<void>(
      '/auth/token',
      data: {'login': 'user', 'password': 'password'},
      options: Options(extra: {ApiEndpoints.requiresAuthKey: false}),
    );

    expect(tokenWasRead, isFalse);
    expect(adapter.request?.headers['Authorization'], isNull);
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

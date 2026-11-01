import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/profile_remote_data_source.dart';

void main() {
  test('only boolean true enables account deletion', () async {
    final api = _Api();
    final source = ProfileRemoteDataSource(api);
    for (final status in [true, false, null, 'true']) {
      api.body = {
        'success': true,
        'data': {'status': status},
      };
      expect(await source.canDeleteAccount(), status == true);
      expect(api.path, 'api/v1/delete-account');
      expect(api.posts, 0);
    }
    api.body = {'status': true};
    expect(await source.canDeleteAccount(), true);
  });
  test(
    'confirmation posts expected payload and rejects unsuccessful responses',
    () async {
      final api = _Api();
      final source = ProfileRemoteDataSource(api);
      api.body = {'success': true};
      await source.deleteAccount();
      expect(api.path, 'api/v1/delete-account');
      expect(api.payload, {'status': true});
      for (final body in [
        null,
        {'success': false},
        {'status': true},
      ]) {
        api.body = body;
        await expectLater(source.deleteAccount(), throwsFormatException);
      }
    },
  );
}

class _Api extends ApiService {
  _Api() : super(Dio());
  dynamic body;
  String? path;
  Object? payload;
  int posts = 0;
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    this.path = path;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: body as T?,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    posts++;
    this.path = path;
    payload = data;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: body as T?,
    );
  }
}

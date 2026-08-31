import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class SupportContentRemoteDataSource {
  const SupportContentRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<Object> fetch(String path) async {
    final response = await _apiService.get<dynamic>(
      path,
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] == null) {
      final message = body is Map ? body['message']?.toString() : null;
      throw FormatException(message ?? 'Could not load this page.');
    }
    return body['data'] as Object;
  }
}

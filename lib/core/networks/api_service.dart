import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class ApiService extends GetxService {
  ApiService(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.get<T>(path, queryParameters: queryParameters, options: options),
  );

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
  );

  Future<Response<T>> put<T>(String path, {Object? data, Options? options}) =>
      _request(() => _dio.put<T>(path, data: data, options: options));

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) => _request(() => _dio.delete<T>(path, data: data, options: options));

  Future<Response<T>> _request<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      for (final key in const ['message', 'error', 'detail']) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
        if (value is Map && value['details'] != null) {
          return value['details'].toString();
        }
      }
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'The request timed out. Please try again.',
      DioExceptionType.connectionError => 'Unable to connect to the server.',
      _ => error.message ?? 'Something went wrong.',
    };
  }
}

import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/constants/api_constants.dart';
import 'package:mobile_hexy/core/error/exceptions.dart';
import 'package:mobile_hexy/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'login': login, 'password': password},
        options: Options(extra: {ApiConstants.requiresAuthKey: false}),
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('The server returned an empty response.');
      }
      return AuthSessionModel.fromJson(body);
    } on DioException catch (error) {
      throw ServerException(_messageFrom(error));
    }
  }

  String _messageFrom(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      for (final key in const ['message', 'error', 'detail']) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The request timed out. Please try again.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }
    return 'Login failed. Please check your credentials.';
  }
}

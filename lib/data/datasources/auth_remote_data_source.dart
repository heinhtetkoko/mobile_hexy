import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/request/login_request.dart';
import 'package:mobile_hexy/data/models/request/signup_request.dart';
import 'package:mobile_hexy/data/models/response/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<AuthSessionModel> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: LoginRequest(login: login, password: password).toJson(),
        options: Options(extra: {ApiEndpoints.requiresAuthKey: false}),
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('The server returned an empty response.');
      }
      return AuthSessionModel.fromJson(body);
    } on ServerException {
      rethrow;
    } on Exception catch (error) {
      throw ServerException(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<AuthSessionModel> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.signup,
        data: SignupRequest(
          username: username,
          email: email,
          password: password,
        ).toJson(),
        options: Options(extra: {ApiEndpoints.requiresAuthKey: false}),
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('The server returned an empty response.');
      }
      return AuthSessionModel.fromJson(body);
    } on ServerException {
      rethrow;
    } on Exception catch (error) {
      throw ServerException(error.toString().replaceFirst('Exception: ', ''));
    }
  }
}

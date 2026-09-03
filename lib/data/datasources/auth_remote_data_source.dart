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

  Future<AuthSessionModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.googleLogin,
        data: {'id_token': idToken},
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

  Future<void> requestPasswordOtp(String email) async {
    await _publicPost(ApiEndpoints.forgotPasswordRequest, {'email': email});
  }

  Future<String> verifyPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final data = await _publicPost(ApiEndpoints.forgotPasswordVerify, {
      'email': email,
      'otp': otp,
    });
    final token = data['reset_token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ServerException(
        'The verification response did not contain a reset token.',
      );
    }
    return token;
  }

  Future<String?> resetForgottenPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final data = await _publicPost(ApiEndpoints.forgotPasswordReset, {
      'reset_token': resetToken,
      'new_password': newPassword,
      'confirm_password': newPassword,
    });
    final token = data['access_token']?.toString();
    return token?.isNotEmpty == true ? token : null;
  }

  Future<Map<String, dynamic>> _publicPost(
    String path,
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await _apiService.post<dynamic>(
        path,
        data: request,
        options: Options(extra: {ApiEndpoints.requiresAuthKey: false}),
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw ServerException(
          body is Map
              ? body['message']?.toString() ?? 'Password reset failed.'
              : 'The server returned an invalid response.',
        );
      }
      final data = body['data'];
      return data is Map ? Map<String, dynamic>.from(data) : const {};
    } on ServerException {
      rethrow;
    } on Exception catch (error) {
      throw ServerException(error.toString().replaceFirst('Exception: ', ''));
    }
  }
}

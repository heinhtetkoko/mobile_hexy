import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_log_interceptor.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();
typedef UnauthorizedCallback = FutureOr<void> Function(bool hadAccessToken);

/// Builds the app's shared HTTP client.
///
/// Feature data sources should receive [Dio] through dependency injection
/// instead of creating their own client. Supply [accessTokenProvider] once an
/// authentication storage implementation is available.
abstract final class DioClient {
  static const _hadAccessTokenKey = 'hadAccessToken';
  static Dio create({
    String baseUrl = ApiEndpoints.baseUrl,
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedCallback? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth =
              options.extra[ApiEndpoints.requiresAuthKey] as bool? ?? true;
          if (!requiresAuth) {
            return handler.next(options);
          }

          final token = await accessTokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            options.extra[_hadAccessTokenKey] = true;
          } else if (options.extra[ApiEndpoints.redirectOnUnauthorizedKey] ==
              true) {
            await onUnauthorized?.call(false);
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 401,
                  data: const {
                    'success': false,
                    'message': 'Authentication required',
                  },
                ),
                type: DioExceptionType.badResponse,
                message: 'Authentication required',
              ),
            );
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requiresAuth =
              error.requestOptions.extra[ApiEndpoints.requiresAuthKey]
                  as bool? ??
              true;
          final hadAccessToken =
              error.requestOptions.extra[_hadAccessTokenKey] == true;
          final redirectOnUnauthorized =
              error.requestOptions.extra[ApiEndpoints
                  .redirectOnUnauthorizedKey] ==
              true;
          if (requiresAuth &&
              (hadAccessToken || redirectOnUnauthorized) &&
              error.response?.statusCode == 401) {
            await onUnauthorized?.call(hadAccessToken);
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(ApiLogInterceptor());
    }

    return dio;
  }
}

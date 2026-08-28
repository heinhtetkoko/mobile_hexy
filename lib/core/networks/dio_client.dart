import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_log_interceptor.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();

/// Builds the app's shared HTTP client.
///
/// Feature data sources should receive [Dio] through dependency injection
/// instead of creating their own client. Supply [accessTokenProvider] once an
/// authentication storage implementation is available.
abstract final class DioClient {
  static Dio create({
    String baseUrl = ApiEndpoints.baseUrl,
    AccessTokenProvider? accessTokenProvider,
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
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(ApiLogInterceptor());
    }

    return dio;
  }
}

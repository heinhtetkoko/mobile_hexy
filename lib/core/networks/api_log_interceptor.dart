import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs complete API traffic in debug builds.
class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── API REQUEST ─────────────────────────────');
    debugPrint('│ ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${_encode(_redact(options.headers))}');
    debugPrint('│ Body: ${_encode(_redact(options.data))}');
    debugPrint('└────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('┌── API RESPONSE ────────────────────────────');
    debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Body: ${_encode(response.data)}');
    debugPrint('└────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌── API ERROR ───────────────────────────────');
    debugPrint('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('│ Status: ${err.response?.statusCode ?? 'no response'}');
    debugPrint('│ Type: ${err.type.name}');
    debugPrint('│ Message: ${err.message ?? 'none'}');
    debugPrint('│ Cause: ${err.error ?? 'none'}');
    debugPrint(
      '│ Request headers: ${_encode(_redact(err.requestOptions.headers))}',
    );
    debugPrint('│ Request body: ${_encode(_redact(err.requestOptions.data))}');
    debugPrint('│ Response body: ${_encode(err.response?.data)}');
    debugPrint('└────────────────────────────────────────────');
    handler.next(err);
  }

  String _encode(Object? value) {
    if (value == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      return value.toString();
    }
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key.toString().toLowerCase();
        const sensitiveKeys = {
          'authorization',
          'password',
          'access_token',
          'refresh_token',
          'id_token',
          'token',
        };
        return MapEntry(
          key,
          sensitiveKeys.contains(normalizedKey) ? '***' : _redact(item),
        );
      });
    }
    if (value is List) return value.map(_redact).toList(growable: false);
    return value;
  }
}

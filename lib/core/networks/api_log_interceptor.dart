import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs complete API traffic in debug builds.
class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── API REQUEST ─────────────────────────────');
    debugPrint('│ ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${_encode(options.headers)}');
    debugPrint('│ Body: ${_encode(options.data)}');
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
    debugPrint('│ Request headers: ${_encode(err.requestOptions.headers)}');
    debugPrint('│ Request body: ${_encode(err.requestOptions.data)}');
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
}

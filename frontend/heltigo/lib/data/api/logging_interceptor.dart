/// LoggingInterceptor — log request/response untuk debugging.
/// Hanya aktif di debug build (kDebugMode).
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.d('→ ${options.method} ${options.uri}');
      if (options.data != null) {
        _logger.d('  body: ${_truncate(options.data.toString())}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.w(
        '✗ ${err.response?.statusCode ?? "—"} ${err.requestOptions.uri}: ${err.message}',
      );
    }
    handler.next(err);
  }

  String _truncate(String s, [int max = 300]) =>
      s.length > max ? '${s.substring(0, max)}...' : s;
}

/// Heltigo API Service — Dio HTTP client dengan 3 interceptor:
/// - AuthInterceptor → inject JWT + ngrok-skip header
/// - ErrorInterceptor → handle 401 refresh + mapping error → ApiException
/// - LoggingInterceptor → debug log
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'endpoints.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';
import 'package:heltigo/services/secure_storage_service.dart';

class ApiService {
  late final Dio _dio;
  final Logger _logger;
  final SecureStorageService _storage;

  ApiService(this._storage, this._logger) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(ErrorInterceptor(_dio, _storage, _logger));
    _dio.interceptors.add(LoggingInterceptor(_logger));
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  /// PATCH request
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  /// DELETE request
  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}

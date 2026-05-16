/// Heltigo API Service — Dio HTTP client wrapper
/// Sumber: docs/frontend/08_API_INTEGRATION.md
///
/// Menggunakan Dio dengan interceptors:
/// - AuthInterceptor → inject JWT token di setiap request
/// - ErrorInterceptor → handle 401/403/500 secara global
/// - LoggingInterceptor → log request/response untuk debugging
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'endpoints.dart';

class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // TODO: Tambahkan AuthInterceptor untuk inject JWT
    // TODO: Tambahkan ErrorInterceptor untuk global error handling
    // TODO: Tambahkan LoggingInterceptor untuk debug
  }

  Dio get dio => _dio;

  /// Set auth token setelah login
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token saat logout
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _logger.d('GET $path');
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data}) async {
    _logger.d('POST $path');
    return _dio.post(path, data: data);
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data}) async {
    _logger.d('PUT $path');
    return _dio.put(path, data: data);
  }

  /// PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    _logger.d('PATCH $path');
    return _dio.patch(path, data: data);
  }

  /// DELETE request
  Future<Response> delete(String path) async {
    _logger.d('DELETE $path');
    return _dio.delete(path);
  }
}

/// AuthInterceptor — auto-inject `Authorization: Bearer <accessToken>` ke
/// setiap request kecuali endpoint public (login, register, refresh, dst).
///
/// Juga inject header `ngrok-skip-browser-warning: true` supaya request ke
/// ngrok free tier tidak ter-block oleh warning page HTML.
import 'package:dio/dio.dart';
import 'package:heltigo/services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  /// Endpoint yang TIDAK butuh token (sebelum login). Path relatif ke baseUrl.
  static const _publicPaths = <String>{
    '/auth/register',
    '/auth/login',
    '/auth/refresh-token',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  bool _isPublic(String path) {
    return _publicPaths.any((p) => path.endsWith(p));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Header anti-warning untuk ngrok free tier.
    options.headers['ngrok-skip-browser-warning'] = 'true';

    if (!_isPublic(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

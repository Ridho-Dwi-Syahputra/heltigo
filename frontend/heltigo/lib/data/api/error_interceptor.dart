/// ErrorInterceptor — global error handling.
///
/// 1. Kalau response 401 (TOKEN_EXPIRED), coba refresh dengan refreshToken
///    yang tersimpan. Jika sukses, retry request original. Jika refresh juga
///    gagal, clear tokens (FE harus navigate ke /login via redirect router).
/// 2. Map semua DioException ke ApiException yang user-friendly.
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'api_exception.dart';
import 'endpoints.dart';
import 'package:heltigo/services/secure_storage_service.dart';

class ErrorInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  final Logger _logger;

  /// Lock supaya ketika banyak request gagal bersamaan, refresh hanya 1x.
  bool _isRefreshing = false;

  ErrorInterceptor(this._dio, this._storage, this._logger);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestPath = err.requestOptions.path;

    // Network error / no response
    if (response == null) {
      _logger.w('Network error on $requestPath: ${err.message}');
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException(
            statusCode: 0,
            code: 'NETWORK_ERROR',
            message: _networkErrorMessage(err),
          ),
        ),
      );
    }

    final data = response.data;
    final errorPayload = data is Map<String, dynamic> ? data['error'] : null;
    final code = errorPayload is Map ? errorPayload['code'] as String? : null;
    final message =
        errorPayload is Map ? errorPayload['message'] as String? : null;

    // 401 → coba refresh token (kecuali endpoint refresh itu sendiri)
    if (response.statusCode == 401 &&
        !requestPath.endsWith(ApiEndpoints.refreshToken) &&
        !requestPath.endsWith(ApiEndpoints.login)) {
      final ok = await _tryRefresh();
      if (ok) {
        // Retry original request dengan token baru
        try {
          final retried = await _retryWithNewToken(err.requestOptions);
          return handler.resolve(retried);
        } catch (e) {
          // fall through ke reject
        }
      } else {
        // Refresh gagal → clear tokens; FE router akan redirect ke /login
        await _storage.clear();
      }
    }

    final apiError = ApiException(
      statusCode: response.statusCode ?? 0,
      code: code ?? 'UNKNOWN_ERROR',
      message: message ?? _statusMessage(response.statusCode),
      details: data,
    );

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: response,
      type: err.type,
      error: apiError,
    ));
  }

  Future<bool> _tryRefresh() async {
    if (_isRefreshing) {
      // Tunggu sampai refresh selesai
      await Future.delayed(const Duration(milliseconds: 100));
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      final t = await _storage.getAccessToken();
      return t != null && t.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Pakai Dio terpisah agar tidak rekursif lewat interceptor ini.
      final freshDio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ));

      final resp = await freshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccess = resp.data['accessToken'] as String?;
      final newRefresh = resp.data['refreshToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) return false;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? refreshToken,
      );
      _logger.i('Token refreshed');
      return true;
    } catch (e) {
      _logger.w('Refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retryWithNewToken(RequestOptions opts) async {
    final newToken = await _storage.getAccessToken();
    opts.headers['Authorization'] = 'Bearer $newToken';
    return _dio.fetch(opts);
  }

  String _networkErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi timeout. Pastikan internet aktif.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Kesalahan jaringan. Coba lagi.';
    }
  }

  String _statusMessage(int? status) {
    switch (status) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi berakhir, silakan login ulang.';
      case 403:
        return 'Akses ditolak.';
      case 404:
        return 'Data tidak ditemukan.';
      case 409:
        return 'Konflik data.';
      case 422:
        return 'Input tidak valid.';
      case 500:
        return 'Kesalahan server.';
      case 502:
        return 'Layanan AI sementara tidak tersedia.';
      case 503:
        return 'Layanan tidak tersedia.';
      default:
        return 'Terjadi kesalahan ($status).';
    }
  }
}

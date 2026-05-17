/// Exception class untuk error API.
/// Dilempar oleh `ErrorInterceptor` setelah mapping `DioException` ke pesan
/// user-friendly Bahasa Indonesia.
class ApiException implements Exception {
  /// HTTP status code (0 = network/timeout error).
  final int statusCode;

  /// Kode error dari backend (mis. `INVALID_CREDENTIALS`, `ML_TIMEOUT`).
  final String code;

  /// Pesan yang sudah dilokalisasi Bahasa Indonesia.
  final String message;

  /// Raw payload dari backend (untuk debugging).
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;

  /// Apakah error ini disebabkan token kadaluarsa atau invalid.
  bool get isAuthError =>
      statusCode == 401 ||
      code == 'TOKEN_EXPIRED' ||
      code == 'TOKEN_INVALID' ||
      code == 'REFRESH_INVALID';

  /// Apakah error berasal dari network (offline / timeout).
  bool get isNetworkError =>
      statusCode == 0 ||
      code == 'NETWORK_ERROR' ||
      code == 'CONNECTION_TIMEOUT' ||
      code == 'ML_TIMEOUT' ||
      code == 'ML_UNREACHABLE';
}

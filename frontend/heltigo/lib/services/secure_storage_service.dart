/// Secure Storage Service — wrapper `flutter_secure_storage` untuk token
/// JWT dan refresh token. Pakai Keychain di iOS, EncryptedSharedPreferences
/// di Android (M+).
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }

  /// Cek apakah ada access token yang tersimpan (digunakan oleh auth guard).
  Future<bool> hasToken() async {
    final t = await _storage.read(key: _kAccessToken);
    return t != null && t.isNotEmpty;
  }
}

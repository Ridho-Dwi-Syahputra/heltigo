/// Auth Provider — state management untuk autentikasi.
/// Token disimpan di flutter_secure_storage via [SecureStorageService].
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/auth_repository.dart';
import 'package:heltigo/data/models/user_model.dart';
import 'package:heltigo/services/secure_storage_service.dart';
import 'package:heltigo/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SecureStorageService _storage;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _hasHealthProfile = false;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider(this._authRepository) : _storage = getIt<SecureStorageService>();

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasHealthProfile => _hasHealthProfile;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  /// Cek token tersimpan saat app startup. Kalau ada token valid → fetch /auth/me.
  Future<void> initialize() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      _isLoggedIn = false;
      return;
    }
    try {
      _user = await _authRepository.getMe();
      _isLoggedIn = true;
      _hasHealthProfile = _user?.hasProfile ?? false;
    } catch (e) {
      // Token tidak valid lagi → clear
      await _storage.clear();
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final auth = await _authRepository.login(email, password);
      await _storage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      _user = auth.user;
      _isLoggedIn = true;
      _hasHealthProfile = auth.user.hasProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _readableError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final auth = await _authRepository.register(email, password, name);
      await _storage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      _user = auth.user;
      _isLoggedIn = true;
      _hasHealthProfile = false; // baru register, belum ada profile
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _readableError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      await _authRepository.logout(refreshToken);
    } catch (_) {
      // tetap logout lokal walau request gagal
    }
    await _storage.clear();
    _user = null;
    _isLoggedIn = false;
    _hasHealthProfile = false;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _readableError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Dipanggil setelah user buat health profile sukses, supaya guard tahu.
  void markProfileCreated() {
    _hasHealthProfile = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _readableError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}

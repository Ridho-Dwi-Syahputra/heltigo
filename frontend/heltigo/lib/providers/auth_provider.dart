/// Auth Provider — state management untuk autentikasi
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heltigo/data/repositories/auth_repository.dart';
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  /// Initialize — cek apakah sudah ada token tersimpan
  Future<void> initialize() async {
    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      getIt<ApiService>().setAuthToken(token);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);
      await _saveTokens(response.accessToken, response.refreshToken);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _authRepository.register(email, password, name);
      await _saveTokens(response.accessToken, response.refreshToken);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // silently fail — tetap logout secara lokal
    }
    final prefs = getIt<SharedPreferences>();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    getIt<ApiService>().clearAuthToken();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    getIt<ApiService>().setAuthToken(accessToken);
  }
}

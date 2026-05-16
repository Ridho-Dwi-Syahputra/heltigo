/// Auth Repository — abstraksi akses data auth
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md (Repository Pattern)
import 'package:heltigo/data/services/auth_service.dart';
import 'package:heltigo/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final json = await _authService.login(email: email, password: password);
    return AuthResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> register(
      String email, String password, String name) async {
    final json = await _authService.register(
        email: email, password: password, name: name);
    return AuthResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final json = await _authService.refreshToken(refreshToken);
    return AuthResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }
}

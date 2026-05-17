/// Auth Repository — abstraksi akses data auth.
/// Backend mengembalikan respons flat (tanpa envelope `data`).
import 'package:heltigo/data/services/auth_service.dart';
import 'package:heltigo/data/models/auth_response_model.dart';
import 'package:heltigo/data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<UserModel> getMe();
  Future<Map<String, String>> refreshToken(String refreshToken);
  Future<void> logout(String? refreshToken);
  Future<Map<String, dynamic>> forgotPassword(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final json = await _authService.login(email: email, password: password);
    return AuthResponse.fromJson(json);
  }

  @override
  Future<AuthResponse> register(
      String email, String password, String name) async {
    final json = await _authService.register(
      email: email,
      password: password,
      name: name,
    );
    return AuthResponse.fromJson(json);
  }

  @override
  Future<UserModel> getMe() async {
    final json = await _authService.getMe();
    final userJson = (json['user'] ?? json) as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    final json = await _authService.refreshToken(refreshToken);
    return {
      'accessToken': json['accessToken'] as String,
      'refreshToken': (json['refreshToken'] ?? refreshToken) as String,
    };
  }

  @override
  Future<void> logout(String? refreshToken) =>
      _authService.logout(refreshToken);

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) =>
      _authService.forgotPassword(email);
}

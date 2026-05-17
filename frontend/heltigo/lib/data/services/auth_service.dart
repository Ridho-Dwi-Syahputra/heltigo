/// Auth Service — komunikasi API untuk auth endpoints.
/// Backend response: flat object (tidak ada envelope `data`).
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _apiService.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name},
    );
    return res.data as Map<String, dynamic>;
  }

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _apiService.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  /// GET /auth/me
  Future<Map<String, dynamic>> getMe() async {
    final res = await _apiService.get(ApiEndpoints.getMe);
    return res.data as Map<String, dynamic>;
  }

  /// POST /auth/refresh-token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await _apiService.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return res.data as Map<String, dynamic>;
  }

  /// POST /auth/logout
  Future<void> logout(String? refreshToken) async {
    await _apiService.post(
      ApiEndpoints.logout,
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }

  /// POST /auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return res.data as Map<String, dynamic>;
  }
}

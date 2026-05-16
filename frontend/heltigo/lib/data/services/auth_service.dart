/// Auth Service — komunikasi API untuk auth endpoints
/// Sumber: docs/frontend/08_API_INTEGRATION.md
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
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /auth/refresh-token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiService.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /auth/logout
  Future<void> logout() async {
    await _apiService.post(ApiEndpoints.logout);
  }
}

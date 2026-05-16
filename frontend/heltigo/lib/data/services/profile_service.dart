/// Profile Service — komunikasi API untuk user profile endpoints
/// Sumber: docs/frontend/08_API_INTEGRATION.md
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  /// GET /user/profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get(ApiEndpoints.profile);
    return response.data as Map<String, dynamic>;
  }

  /// PUT /user/profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await _apiService.put(ApiEndpoints.updateProfile,
        data: data);
    return response.data as Map<String, dynamic>;
  }

  /// GET /user/health-metrics
  Future<Map<String, dynamic>> getHealthMetrics() async {
    final response = await _apiService.get(ApiEndpoints.healthMetrics);
    return response.data as Map<String, dynamic>;
  }

  /// POST /user/health-metrics
  Future<Map<String, dynamic>> saveHealthMetrics(
      Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.healthMetrics, data: data);
    return response.data as Map<String, dynamic>;
  }
}

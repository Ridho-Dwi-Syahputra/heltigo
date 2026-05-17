/// Profile Service — komunikasi API untuk user profile endpoints.
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  /// GET /user/profile
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _apiService.get(ApiEndpoints.profile);
    return res.data as Map<String, dynamic>;
  }

  /// PUT /user/profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _apiService.put(ApiEndpoints.updateProfile, data: data);
    return res.data as Map<String, dynamic>;
  }

  /// PATCH /user/profile/avatar
  Future<Map<String, dynamic>> updateAvatar(String avatarUrl) async {
    final res = await _apiService.patch(
      ApiEndpoints.updateAvatar,
      data: {'avatarUrl': avatarUrl},
    );
    return res.data as Map<String, dynamic>;
  }

  /// POST /user/health-profile (onboarding)
  Future<Map<String, dynamic>> createHealthProfile(
      Map<String, dynamic> data) async {
    final res =
        await _apiService.post(ApiEndpoints.createHealthProfile, data: data);
    return res.data as Map<String, dynamic>;
  }

  /// PUT /user/health-profile
  Future<Map<String, dynamic>> updateHealthProfile(
      Map<String, dynamic> data) async {
    final res =
        await _apiService.put(ApiEndpoints.updateHealthProfile, data: data);
    return res.data as Map<String, dynamic>;
  }

  /// GET /user/health-metrics
  Future<Map<String, dynamic>> getHealthMetrics() async {
    final res = await _apiService.get(ApiEndpoints.healthMetrics);
    return res.data as Map<String, dynamic>;
  }

  /// POST /user/health-metrics
  Future<Map<String, dynamic>> saveHealthMetrics(
      Map<String, dynamic> data) async {
    final res =
        await _apiService.post(ApiEndpoints.healthMetrics, data: data);
    return res.data as Map<String, dynamic>;
  }

  /// GET /user/health-metrics/history?days=30
  Future<Map<String, dynamic>> getHealthMetricsHistory({int days = 30}) async {
    final res = await _apiService.get(
      ApiEndpoints.healthMetricsHistory,
      queryParameters: {'days': days},
    );
    return res.data as Map<String, dynamic>;
  }
}

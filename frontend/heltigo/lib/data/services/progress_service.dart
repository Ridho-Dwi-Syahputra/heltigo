/// Progress Service — komunikasi API untuk progress/streak/badges
/// Sumber: docs/frontend/08_API_INTEGRATION.md
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class ProgressService {
  final ApiService _apiService;

  ProgressService(this._apiService);

  /// GET /progress/weekly — ringkasan progress mingguan
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    final response = await _apiService.get(ApiEndpoints.weeklyProgress);
    return response.data as Map<String, dynamic>;
  }

  /// GET /progress/daily — progress harian
  Future<Map<String, dynamic>> getDailyProgress() async {
    final response = await _apiService.get(ApiEndpoints.dailyProgress);
    return response.data as Map<String, dynamic>;
  }

  /// GET /progress/streak — data streak
  Future<Map<String, dynamic>> getStreak() async {
    final response = await _apiService.get(ApiEndpoints.streak);
    return response.data as Map<String, dynamic>;
  }

  /// GET /progress/badges — daftar badge
  Future<Map<String, dynamic>> getBadges() async {
    final response = await _apiService.get(ApiEndpoints.badges);
    return response.data as Map<String, dynamic>;
  }
}

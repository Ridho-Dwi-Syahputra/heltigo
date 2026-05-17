/// Progress Service — komunikasi API untuk progress, streak, badges.
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class ProgressService {
  final ApiService _apiService;

  ProgressService(this._apiService);

  Future<Map<String, dynamic>> getDailyProgress({String? date}) async {
    final res = await _apiService.get(
      ApiEndpoints.dailyProgress,
      queryParameters: date != null ? {'date': date} : null,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateWater({int? glasses, int? delta}) async {
    final body = <String, dynamic>{};
    if (glasses != null) body['glasses'] = glasses;
    if (delta != null) body['delta'] = delta;
    final res = await _apiService.patch(ApiEndpoints.updateWater, data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logMood(String mood) async {
    final res = await _apiService.post(
      ApiEndpoints.logMood,
      data: {'mood': mood},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeeklyProgress() async {
    final res = await _apiService.get(ApiEndpoints.weeklyProgress);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeeklyReview() async {
    final res = await _apiService.get(ApiEndpoints.weeklyReview);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStreak() async {
    final res = await _apiService.get(ApiEndpoints.streak);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBadges() async {
    final res = await _apiService.get(ApiEndpoints.badges);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBadgeDetail(String code) async {
    final res = await _apiService.get(ApiEndpoints.badgeDetail(code));
    return res.data as Map<String, dynamic>;
  }
}

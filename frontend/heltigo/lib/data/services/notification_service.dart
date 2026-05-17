/// Notification Service — komunikasi API untuk notifications.
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService(this._apiService);

  Future<Map<String, dynamic>> list({
    bool unreadOnly = false,
    int limit = 30,
  }) async {
    final res = await _apiService.get(
      ApiEndpoints.notifications,
      queryParameters: {
        if (unreadOnly) 'unreadOnly': 'true',
        'limit': limit,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final res = await _apiService.patch(ApiEndpoints.markNotificationRead(id));
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _apiService.patch(ApiEndpoints.readAllNotifications);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerFcmToken(
      String token, String platform) async {
    final res = await _apiService.post(
      ApiEndpoints.fcmToken,
      data: {'token': token, 'platform': platform},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteFcmToken(String token) async {
    await _apiService.delete(ApiEndpoints.fcmToken, data: {'token': token});
  }
}

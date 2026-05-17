/// Notification Repository.
import 'package:heltigo/data/services/notification_service.dart';
import 'package:heltigo/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<({List<NotificationModel> items, int unreadCount})> list({
    bool unreadOnly = false,
    int limit = 30,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> registerFcmToken(String token, String platform);
  Future<void> deleteFcmToken(String token);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService _service;

  NotificationRepositoryImpl(this._service);

  @override
  Future<({List<NotificationModel> items, int unreadCount})> list({
    bool unreadOnly = false,
    int limit = 30,
  }) async {
    final json = await _service.list(unreadOnly: unreadOnly, limit: limit);
    final items = (json['items'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList() ??
        [];
    final unread = (json['unreadCount'] as num?)?.toInt() ?? 0;
    return (items: items, unreadCount: unread);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
  }

  @override
  Future<void> registerFcmToken(String token, String platform) async {
    await _service.registerFcmToken(token, platform);
  }

  @override
  Future<void> deleteFcmToken(String token) async {
    await _service.deleteFcmToken(token);
  }
}

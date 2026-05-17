/// Notification Provider — list & mark-as-read.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/notification_repository.dart';
import 'package:heltigo/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;

  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider(this._repo);

  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repo.list(unreadOnly: unreadOnly);
      _items = result.items;
      _unreadCount = result.unreadCount;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String id) async {
    try {
      await _repo.markAsRead(id);
      // Optimistic update lokal
      _items = _items.map((n) {
        if (n.id == id) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            actionUrl: n.actionUrl,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      _items = _items
          .map((n) => NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                actionUrl: n.actionUrl,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: n.createdAt,
              ))
          .toList();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}

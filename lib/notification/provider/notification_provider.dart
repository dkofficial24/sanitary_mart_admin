import 'package:flutter/foundation.dart';
import 'package:sanitary_mart_admin/notification/model/notification_model.dart';
import 'package:sanitary_mart_admin/notification/service/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasMore = true;

  List<NotificationModel> get notifications => _notifications;

  bool get isLoading => _isLoading;

  bool get hasMore => _hasMore;

  // Fetch notifications with lazy loading
  Future<void> fetchNotifications({int limit = 10}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<NotificationModel> newNotifications =
          await _notificationService.fetchNotifications(
        limit: limit,
      );

      if (newNotifications.isNotEmpty) {
        _notifications.addAll(newNotifications);
      } else {
        _hasMore = false; // No more notifications to load
      }
    } catch (e) {
      // Handle error (e.g., log the error or show a message)
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<int> getUnreadNotificationCountStream() {
   return _notificationService.getUnreadNotificationCountStream();
  }

  // Reset the provider state
  void resetNotifications() {
    _notifications.clear();
    _hasMore = true;
    _notificationService.resetLastDocument();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/notification/model/notification_model.dart';
import 'package:sanitary_mart_admin/notification/service/local_notification_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;

  /// Fetch notifications with pagination.
  Future<List<NotificationModel>> fetchNotifications({
    required int limit,
  }) async {
    Query query = _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<NotificationModel> notifications = querySnapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();

    if (notifications.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    } else {
      _lastDocument = null;
    }

    return notifications;
  }

  /// Reset the last document for pagination.
  void resetLastDocument() {
    _lastDocument = null;
  }

  /// Fetch unread notifications count.
  Future<int> getUnreadNotificationCount() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: false)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching unread notification count: $e');
      throw e;
    }
  }

  /// Fetch and listen to unread notifications count.
  Stream<int> getUnreadNotificationCountStream() {
    try {
      return _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'unread')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        return querySnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching unread notification count: $e');
      return Stream<int>.error(e);
    }
  }

  /// Mark a notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'read',
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }

  /// Listen for new notifications and show a local notification.
  void listenForNewNotifications() {
    try {
      _firestore.collection('notifications').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            NotificationModel notification =
                NotificationModel.fromFirestore(change.doc);
            if (notification.status == 'read') {
              return;
            }
            LocalNotificationService.showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: 'Order Received From ${notification.userName}',
              body:
                  'Quantity: ${notification.noOfItem} OrderId: ${notification.orderId}',
            );
          }
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

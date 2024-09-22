import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/notification/model/notification_model.dart';
import 'package:sanitary_mart_admin/notification/service/notification_service.dart';
import 'package:sanitary_mart_admin/order/ui/user_order_list_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    try {
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Set your launcher icon here
        iOS: DarwinInitializationSettings(),
      );

      _notificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse:
              (NotificationResponse response) async {
        if (response.payload != null) {
          NotificationModel notificationModel =
              NotificationModel.fromJson(jsonDecode(response.payload!));
          Get.to(UserOrderListScreen(
            userId: notificationModel.userId,
            orderId: notificationModel.orderId,
          ));
          if (notificationModel.id != null) {
            Get.find<NotificationService>().markNotificationAsRead(
              notificationModel.id!,
            );
          }
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> showNotification(
      {required int id,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id', // Channel ID
        'your_channel_name', // Channel Name
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    String payloadStr = jsonEncode(payload);
    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payloadStr);
  }
}

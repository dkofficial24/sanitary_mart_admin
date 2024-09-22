import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/app_util.dart';
import 'package:sanitary_mart_admin/notification/model/notification_model.dart';
import 'package:sanitary_mart_admin/notification/provider/notification_provider.dart';
import 'package:sanitary_mart_admin/order/ui/user_order_list_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const NotificationList(),
    );
  }
}

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late NotificationProvider _provider;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchNotifications();
    });
  }

  void fetchNotifications() {
    _provider = Provider.of<NotificationProvider>(context, listen: false);
    _provider.resetNotifications();
    _provider.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!provider.isLoading &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              provider.fetchNotifications();
              return true;
            }
            return false;
          },
          child: ListView.builder(
            itemCount: provider.notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.notifications.length) {
                return provider.hasMore
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text(''));
              }

              NotificationModel notification = provider.notifications[index];
              return GestureDetector(
                  onDoubleTap: () {
                    //OrderDetailScreen
                  },
                  child: CustomNotificationTile(notification: notification));
            },
          ),
        );
      },
    );
  }
}

class CustomNotificationTile extends StatefulWidget {
  final NotificationModel notification;

  const CustomNotificationTile({super.key, required this.notification});

  @override
  _CustomNotificationTileState createState() => _CustomNotificationTileState();
}

class _CustomNotificationTileState extends State<CustomNotificationTile> {
  Timer? _visibilityTimer;

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.5 && widget.notification.status == 'unread') {
      // If more than 50% of the widget is visible and the notification is not read
      _visibilityTimer?.cancel();
      _visibilityTimer = Timer(const Duration(seconds: 1), _markAsRead);
    } else {
      _visibilityTimer?.cancel();
    }
  }

  void _markAsRead() {
    setState(() {
      widget.notification.status = 'read';
    });

    // Update the status on Firebase
    Provider.of<NotificationProvider>(context, listen: false)
        .markNotificationAsRead(widget.notification.id!);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.notification.id!),
      onVisibilityChanged: _onVisibilityChanged,
      child: Card(
        color: widget.notification.status == 'read'
            ? const Color(0xFFFFFFFF)
            : const Color(0xFFE3F2FD),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          onLongPress: () {
            FlutterClipboard.copy(widget.notification.orderId)
                .then((value) => AppUtil.showToast('OrderId Copied'));
          },
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              widget.notification.userName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            widget.notification.userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Orders id: ${widget.notification.orderId}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Orders Qty: ${widget.notification.noOfItem}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Time: ${AppUtil.convertTimestampInDateTime(widget.notification.timestamp)}',
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.to(UserOrderListScreen(
              userId: widget.notification.userId,
              orderId: widget.notification.orderId,
            ));
          },
        ),
      ),
    );
  }
}

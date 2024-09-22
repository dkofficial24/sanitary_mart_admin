import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  final String orderId;
  final String userId;
  final String userName;
  final int noOfItem;
  final int timestamp;
   String status;
  final String type;

  NotificationModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.noOfItem,
    required this.timestamp,
    required this.status,
    required this.type,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data =
    doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      orderId: data['orderId'],
      userId: data['userId'],
      userName: data['userName'],
      noOfItem: data['noOfItem'],
      timestamp: data['timestamp'],
      status: data['status'],
      type: data['type'],
    );
  }

  factory NotificationModel.fromJson(Map<String,dynamic> data) {
    return NotificationModel(
      id: data['id'],
      orderId: data['orderId'],
      userId: data['userId'],
      userName: data['userName'],
      noOfItem: data['noOfItem'],
      timestamp: data['timestamp'],
      status: data['status'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'noOfItem': noOfItem,
      'timestamp': timestamp,
      'status': status,
      'type': type,
    };
  }
}

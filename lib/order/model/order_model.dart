import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_item.dart';

class OrderModel {
  String orderId;
  List<OrderItem> orderItems;
  int? createdAt;
  int? updatedAt;
  bool orderStatus;
  Customer? customer;

  OrderModel({
    required this.orderId,
    required this.orderItems,
    this.customer,
    this.orderStatus = false,
    this.createdAt,
    this.updatedAt,
  });

  // Convert OrderModel instance to Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'orderStatus': orderStatus,
    };
  }

  // Construct an OrderModel instance from a Map
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['orderItems'] as List;
    List<OrderItem> orderItemsList =
        list.map((i) => OrderItem.fromJson(i)).toList();
    return OrderModel(
      orderId: json['orderId'],
      orderItems: orderItemsList,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      orderStatus: json['orderStatus'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

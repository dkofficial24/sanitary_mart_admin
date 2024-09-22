import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';

class OrderFirebaseService {
  // Future<List<OrderModel>> fetchUserOrders(String uId) async {
  //   final allUsersSnapshot =
  //   await FirebaseFirestore.instance.collection('orders').get();
  //
  //   ///Map<Customer, List<OrderModel>> userOrdersMap = {};
  //     final ordersSnapshot = await FirebaseFirestore.instance
  //         .collection('orders')
  //         .doc(uId)
  //         .collection('confirmOrders')
  //         .orderBy('createdAt', descending: true)
  //         .get();
  //
  //     List<OrderModel> orders = ordersSnapshot.docs.map((doc) {
  //       OrderModel orderModel = OrderModel.fromJson(doc.data());
  //       orderModel.customer = customer;
  //       return orderModel;
  //     }).toList();
  //
  //     userOrdersMap[customer] = orders;
  //
  //
  //   return userOrdersMap;
  // }

  Future<Map<Customer, List<OrderModel>>> fetchAllUserOrders() async {
    final allUsersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    Map<Customer, List<OrderModel>> userOrdersMap = {};

    for (var userDoc in allUsersSnapshot.docs) {
      String uId = userDoc.id;
      Customer customer = Customer.fromJson(userDoc.data());

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(uId)
          .collection('confirmOrders')
          .orderBy('createdAt', descending: true)
          .get();

      List<OrderModel> orders = ordersSnapshot.docs.map((doc) {
        OrderModel orderModel = OrderModel.fromJson(doc.data());
        orderModel.customer = customer;
        return orderModel;
      }).toList();

      userOrdersMap[customer] = orders;
    }

    return userOrdersMap;
  }

  Future updateOrderStatus(String uId, OrderModel orderModel) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(uId)
        .collection('confirmOrders')
        .doc(orderModel.orderId)
        .update({'orderStatus': orderModel.orderStatus.name});
  }

  Future<List<OrderModel>> fetchUserOrders(String uId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('orders').doc(uId).get();

    if (!userSnapshot.exists) {
      return [];
    }
    Customer customer =
        Customer.fromJson(userSnapshot.data() as Map<String, dynamic>);

    final ordersSnapshot = (await FirebaseFirestore.instance
        .collection('orders')
        .doc(uId)
        .collection('confirmOrders')
        .orderBy('createdAt', descending: true)
        .get());

    final orders = ordersSnapshot.docs.map((doc) {
      print('');
      OrderModel orderModel = OrderModel.fromJson(doc.data());
      orderModel.customer = customer;
      return orderModel;
    }).toList();

    return orders;
  }

  Future<OrderModel> fetchOrder(String userId, String orderId) async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(userId)
        .collection('confirmOrders')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      // Parse the document data into an OrderModel object
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;
      return OrderModel.fromJson(orderData);
    } else {
      throw 'Order not found';
    }
  }
}

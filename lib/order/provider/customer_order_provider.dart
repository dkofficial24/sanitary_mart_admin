import 'package:flutter/cupertino.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/service/order_firebase_service.dart';

class CustomerOrderProvider extends ChangeNotifier {
  CustomerOrderProvider(this.orderFirebaseService);

  final OrderFirebaseService orderFirebaseService;
  List<OrderModel> customerOrders = [];
  ProviderState providerState = ProviderState.idle;
  Customer? customer;

  Future fetchUserOrders(String uId,String orderId) async {
    customerOrders = [];
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      customerOrders = [await orderFirebaseService.fetchOrder(uId,orderId)];
      customer = customerOrders.isNotEmpty ? customerOrders[0].customer : null;
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
      AppUtil.showToast(e.toString());
    } finally {
      notifyListeners();
    }
  }
}

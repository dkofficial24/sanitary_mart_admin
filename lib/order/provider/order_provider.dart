import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/service/order_firebase_service.dart';
import 'package:sanitary_mart_admin/product/service/product_service.dart';


class OrderProvider extends ChangeNotifier {
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  Map<Customer, List<OrderModel>>? customerOrders;

  Future loadOrders() async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      customerOrders =
          await Get.find<OrderFirebaseService>().fetchAllUserOrders();
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
      AppUtil.showToast(e.toString());
      Log.e(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future updateOrderStatus(OrderModel orderModel) async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      await (Get.find<OrderFirebaseService>()
          .updateOrderStatus(orderModel.customer!.uId, orderModel));
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
      AppUtil.showToast(e.toString());
      Log.e(e.toString());
    } finally {
      notifyListeners();
    }
  }

}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/service/order_firebase_service.dart';

class OrderProvider extends ChangeNotifier {
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  Map<Customer, List<OrderModel>>? customerOrders;
  Map<Customer, List<OrderModel>>? filteredCustomerOrders;

  Future loadOrders() async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      customerOrders =
      await Get.find<OrderFirebaseService>().fetchAllUserOrders();
      filteredCustomerOrders = customerOrders;
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
      AppUtil.showToast(e.toString());
      Log.e(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      filteredCustomerOrders = customerOrders;
    } else {
      filteredCustomerOrders = customerOrders?.entries
          .where((entry) =>
      entry.key.userName.contains(query) ||
          entry.key.email.contains(query) ||
          (entry.key.phone?.contains(query) ?? false))
          .map((entry) => MapEntry(entry.key, entry.value))
          .toMap();
    }
    notifyListeners();
  }

  Future updateOrderStatus(OrderModel orderModel) async {
    try {
      _state = ProviderState.loading;
      notifyListeners();
      await Get.find<OrderFirebaseService>()
          .updateOrderStatus(orderModel.customer!.uId, orderModel);
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

extension MapExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() {
    return Map<K, V>.fromEntries(this);
  }
}

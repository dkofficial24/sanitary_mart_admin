import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/customer/service/customer_firebase_service.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  ProviderState _state = ProviderState.idle;

  ProviderState get state => _state;

  List<Customer>? customers;

  Future<void> fetchCustomers() async {
    try {
      _state = ProviderState.loading;
      customers = await CustomerFirebaseService().fetchCustomers();
      _state = ProviderState.idle;
    } catch (e) {
      _state = ProviderState.error;
      Log.e(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> setVerificationStatus(String customerId,bool status) async {
    try {
      _state = ProviderState.loading;
      await CustomerFirebaseService().setVerificationStatus(customerId,status);
      _state = ProviderState.idle;
      await fetchCustomers();
    } catch (e) {
      _state = ProviderState.error;
      Log.e(e.toString());
    } finally {
      notifyListeners();
    }
  }

}

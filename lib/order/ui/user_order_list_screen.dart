import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/order/provider/customer_order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/order_detail_screen.dart';

class UserOrderListScreen extends StatefulWidget {
  const UserOrderListScreen(
      {required this.userId, required this.orderId, super.key});

  final String userId;
  final String orderId;

  @override
  State<UserOrderListScreen> createState() => _UserOrderListScreenState();
}

class _UserOrderListScreenState extends State<UserOrderListScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      loadOrders();
    });
    super.initState();
  }

  Future loadOrders() async {
    final orderProvider =
        Provider.of<CustomerOrderProvider>(context, listen: false);
    await orderProvider.fetchUserOrders(widget.userId, widget.orderId);
    if (orderProvider.providerState == ProviderState.idle &&
        orderProvider.customer != null) {
      Get.off(OrderDetailScreen(
          orderProvider.customer!, orderProvider.customerOrders));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CustomerOrderProvider>(
        builder: (BuildContext context, provider, Widget? child) {
          if (provider.providerState == ProviderState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.providerState == ProviderState.error) {
            return ErrorRetryWidget(onRetry: () {
              loadOrders();
            });
          }
          return const Center(
            child: Text('Please wait'),
          );
        },
      ),
    );
  }
}

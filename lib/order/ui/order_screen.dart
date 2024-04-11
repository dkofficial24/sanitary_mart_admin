import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Orders'),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.customerOrders == null ||
              provider.customerOrders!.isEmpty) {
            return Center(
              child: Text(
                'There are no orders yet.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            );
          }
          if (provider.state == ProviderState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: provider.customerOrders!.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final customerOrder =
                  provider.customerOrders!.entries.toList()[index];
              final customer = customerOrder.key;
              final orders = customerOrder.value;
              return ListTile(
                title: Text(customer.userName),
                subtitle: Text(customer.email),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: (){
                  Get.to( OrderDetailScreen(customer,orders));
                },
                // Add more customer details as needed
              );
            },
          );
        },
      ),
    );
  }
}

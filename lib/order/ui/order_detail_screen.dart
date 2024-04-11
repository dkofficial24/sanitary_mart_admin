import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/widget/order_card_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(this.customer, this.orders, {super.key});

  final Customer customer;
  final List<OrderModel> orders;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
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
          return Column(
            children: [
              ListTile(
                title: Text(widget.customer.userName),
                subtitle: Text(widget.customer.email),
                // Add more customer details as needed
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,

                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    final order = widget.orders[index];
                    return OrderCard(order: order);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

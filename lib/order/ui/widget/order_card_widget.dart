import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/widget/custom_auto_complete_widget.dart';
import 'package:sanitary_mart_admin/core/widget/widget.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/model/order_status.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({required this.order, super.key});

  final OrderModel order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  OrderStatus? selectedOrderStatus;

  @override
  void initState() {
    selectedOrderStatus = widget.order.orderStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    double discount = 0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order.orderId}',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Date: ${_formatDate(widget.order.createdAt)}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Status'),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.5,
                  child: CustomAutoCompleteWidget<String>(
                    label: '',
                    initailValue: selectedOrderStatus?.name.capitalizeFirst,
                    options: OrderStatus.values
                        .map((e) => e.name.capitalizeFirst.toString())
                        .toList(),
                    onSuggestionSelected: (String? orderStatus) {
                      if (orderStatus == null) return;
                      setState(() {
                        selectedOrderStatus = parseOrderStatus(orderStatus);
                      });
                      widget.order.orderStatus = selectedOrderStatus!;
                      Provider.of<OrderProvider>(context,listen: false).updateOrderStatus(
                        widget.order,
                      );
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            ...widget.order.orderItems.map((item) {
              total = total + (item.price * item.quantity);
              discount = discount + (item.discountAmount * item.quantity);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      // Rounded corners
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: NetworkImageWidget(
                          item.productImg ?? '',
                        ),
                      ),
                    ),
                    title: Text(item.productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Brand: ${item.brand}'),
                        Text('Quantity: ${item.quantity}'),
                      ],
                    ),
                    trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                  ),
                ],
              );
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:'),
                      Text(total.toString()),
                    ],
                  ),
                  if (discount > 0 && widget.order.userVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points:',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text((discount / 10).toStringAsFixed(2),
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
  }
}

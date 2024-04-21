import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanitary_mart_admin/core/widget/widget.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

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
              'Order ID: ${order.orderId}',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Date: ${_formatDate(order.createdAt)}'),
            const SizedBox(height: 10),
            Text('Status: ${order.orderStatus ? "Completed" : "Pending"}'),
            const SizedBox(height: 10),
            const Divider(),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            ...order.orderItems.map((item) {
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
                  if(discount>0)Row(
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

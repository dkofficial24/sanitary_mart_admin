import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/widget/copy_button_widget.dart';
import 'package:sanitary_mart_admin/core/widget/custom_auto_complete_widget.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/model/order_status.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/widget/order_as_pdf.dart';
import 'package:sanitary_mart_admin/product/service/product_service.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({
    required this.order,
    super.key});
   final OrderModel order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  OrderStatus? selectedOrderStatus;
  OrderStatus? prevOrderStatus;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shri Balaji Sanitary & Elec.',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(onPressed: (){
                  shareOrderAsPdf(context,widget.order);
                }, icon: const Icon(Icons.share)) ,IconButton(onPressed: (){
                  downloadOrderAsPdf(context,widget.order);
                }, icon: const Icon(Icons.download))
              ],
            ),
            const Text(
              'Bhiwani Road, Bahal',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const Text(
              'Phone: 9555294879',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Order ID: ${widget.order.orderId}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CopyIconButton(widget.order.orderId)
              ],
            ),
            Text('Date: ${_formatDate(widget.order.createdAt)}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontSize: 14.0)),
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
                      onOrderUpdate(orderStatus, context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 10,
                dataRowMaxHeight: 65,
                columns: const [
                  // DataColumn(label: Text('Sr')),
                  DataColumn(label: SizedBox(child: Text('Items'))),
                  DataColumn(
                    label: Text('Qty'),
                  ),
                  DataColumn(
                    label: Text('Price'),
                  ),
                  DataColumn(
                    label: Text('Total'),
                  ),
                ],
                rows: widget.order.orderItems.map((item) {
                  double itemTotal = item.price * item.quantity;
                  total += itemTotal;
                  discount += item.discountAmount * item.quantity;
                  return DataRow(
                    cells: [
                      // DataCell(Text(
                      //   (widget.order.orderItems.indexOf(item) + 1).toString(),
                      // )),
                      DataCell(
                        SizedBox(
                          child: Text(item.productName),
                          // width: 100,
                        ),
                      ),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text((item.price).toStringAsFixed(2))),
                      DataCell(Text((itemTotal.toStringAsFixed(2)))),
                    ],
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            // Summary Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SubTotal:', style: TextStyle(fontSize: 14.0)),
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  if (discount > 0 && widget.order.userVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points:',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          (discount / 10).toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                        ),
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

  Future onOrderUpdate(String orderStatus, BuildContext context)async {
    setState(() {
      prevOrderStatus = selectedOrderStatus;
      selectedOrderStatus = parseOrderStatus(orderStatus);

      widget.order.orderStatus = selectedOrderStatus!;
    });

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.updateOrderStatus(
      widget.order,
    );

    if (selectedOrderStatus == OrderStatus.delivered) {
      Get.find<ProductService>().updateProductQuantity(
        widget.order.orderItems,
        delivered: true,
      );
    } else {
      if (selectedOrderStatus != prevOrderStatus &&
          prevOrderStatus == OrderStatus.delivered) {
        Get.find<ProductService>().updateProductQuantity(
          widget.order.orderItems,
          delivered: false,
        );
      }
    }

    // if(orderProvider.state != ProviderState.error && mounted) {
    //   orderProvider.loadOrders();
    // }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
  }

  Color getStatusColor(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }
}



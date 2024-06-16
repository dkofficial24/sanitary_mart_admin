import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
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
    Key? key,
  }) : super(key: key);

  final OrderModel order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  OrderStatus? selectedOrderStatus;
  OrderStatus? prevOrderStatus;
  bool isShowingNote = false; // Track whether note bottom sheet is open

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
                Row(
                  children: [
                    if (widget.order.note != null &&
                        widget.order.note!.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _showNoteDetails(context);
                        },
                        icon: const Icon(Icons.note_alt_outlined),
                      ),
                    IconButton(
                      onPressed: () {
                        shareOrderAsPdf(context, widget.order);
                      },
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: () {
                        downloadOrderAsPdf(context, widget.order);
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ),
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
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Details',
                  style:
                  TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                rowItem(
                  'Name:',
                  widget.order.customer?.userName ?? 'Unavailable',
                ),
                rowItem(
                  'Address:',
                  widget.order.customer?.address ?? 'Unavailable',
                ),
                rowItem(
                  'Phone:',
                  (widget.order.customer?.phone != null &&
                      widget.order.customer?.phone != 'null')
                      ? widget.order.customer?.phone ?? 'Unavailable'
                      : 'Unavailable',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Order ID: ${widget.order.orderId}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CopyIconButton(widget.order.orderId),
              ],
            ),
            Text('Date: ${_formatDate(widget.order.createdAt)}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontSize: 14.0)),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
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
                      DataCell(
                        SizedBox(
                          child: Text(item.productName),
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
                      const Text('SubTotal:',
                          style: TextStyle(fontSize: 14.0)),
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
            if (widget.order.note != null && widget.order.note!.isNotEmpty)
              const SizedBox(height: 10),
            if (widget.order.note != null && widget.order.note!.isNotEmpty)
              TextButton(
                onPressed: () {
                  _showNoteDetails(context);
                },
                child: const Text('View Note'),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> onOrderUpdate(String orderStatus, BuildContext context) async {
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
  }

  Widget rowItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
  }

  void _showNoteDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Note',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.order.note!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

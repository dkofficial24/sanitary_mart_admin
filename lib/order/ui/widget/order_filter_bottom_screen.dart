import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/order/model/order_status.dart';

class OrderFilterBottomSheet extends StatefulWidget {
  const OrderFilterBottomSheet(this.callback,
      {this.selectedOrderStatus, Key? key})
      : super(key: key);
  final Function(OrderStatus?) callback;
  final OrderStatus? selectedOrderStatus;

  @override
  _OrderFilterBottomSheetState createState() => _OrderFilterBottomSheetState();
}

class _OrderFilterBottomSheetState extends State<OrderFilterBottomSheet> {
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    _selectedStatus = widget.selectedOrderStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter by Order Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: OrderStatus.values.length,
            itemBuilder: (BuildContext context, int index) {
              OrderStatus status = OrderStatus.values[index];
              return RadioListTile<OrderStatus>(
                title: Text(status.name.capitalizeFirst!.split('.').last),
                value: status,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  widget.callback(_selectedStatus);
                  Navigator.pop(context);
                },
              );
            },
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.callback(null);
              },
              child: const Text('Reset Filter'))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/model/order_status.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/widget/order_card_widget.dart';
import 'package:sanitary_mart_admin/order/ui/widget/order_filter_bottom_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen(this.customer, this.orders, {super.key});

  final Customer customer;
  final List<OrderModel> orders;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderStatus? filterStatus;
  List<OrderModel> filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOrders = widget.orders;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchOrders(_searchController.text);
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      filteredOrders = widget.orders;
    } else {
      filteredOrders = widget.orders
          .where((order) => order.orderId.contains(query))
          .toList();
    }
    setState(() {});
  }

  void filterOrderByStatus(OrderStatus? orderStatus) {
    if (orderStatus == null) {
      resetFilter();
      return;
    }
    filteredOrders = widget.orders
        .where((order) => order.orderStatus == orderStatus)
        .toList();
    setState(() {});
  }

  void resetFilter() {
    filterStatus = null;
    filteredOrders = widget.orders;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Orders',
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width*0.7,
            child: TextField(
              controller: _searchController,

              decoration: const InputDecoration(
                hintText: 'Search by Order ID',
                suffixIcon: Icon(Icons.search,color: Colors.white,),
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return OrderFilterBottomSheet(
                        (orderStatus) {
                      filterStatus = orderStatus;
                      filterOrderByStatus(filterStatus);
                    },
                    selectedOrderStatus: filterStatus,
                  );
                },
              );
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'There are no orders',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  if (filterStatus != null)
                    TextButton(
                      onPressed: resetFilter,
                      child: const Text('Reset Filter'),
                    )
                ],
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
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return OrderCard(
                      order: order,
                      key: UniqueKey(),
                    );
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

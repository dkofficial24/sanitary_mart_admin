import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/translucent_overlay_loader.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/ui/order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      loadOrders();
    });

    _searchController.addListener(_onSearchChanged);
  }

  void loadOrders() {
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  void _onSearchChanged() {
    Provider.of<OrderProvider>(context, listen: false)
        .filterOrders(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: "",
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextField(
            textAlign: TextAlign.start,
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Find order by user details',
              suffixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.idle &&
              (provider.filteredCustomerOrders == null ||
                  provider.filteredCustomerOrders!.isEmpty)) {
            return Center(
              child: Text(
                'There are no orders yet.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            );
          }

          return TranslucentOverlayLoader(
            enabled: provider.state == ProviderState.loading,
            child: ListView.builder(
              itemCount: provider.filteredCustomerOrders?.length ?? 0,
              itemBuilder: (context, index) {
                final customerOrder =
                    provider.filteredCustomerOrders!.entries.toList()[index];
                final customer = customerOrder.key;
                final orders = customerOrder.value;
                return ListTile(
                  title: Text(customer.userName),
                  subtitle: Text(customer.email),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Get.to(OrderDetailScreen(customer, orders));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

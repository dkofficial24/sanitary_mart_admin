import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/customer/provider/customer_provider.dart';
import 'package:sanitary_mart_admin/customer/ui/customer_detail_screen.dart';
import 'package:sanitary_mart_admin/incentive_points/ui/incentive_point_provider.dart';
import 'package:sanitary_mart_admin/incentive_points/ui/screen/incentive_point_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (provider.customers == null || provider.customers!.isEmpty) {
            return Center(
              child: Text(
                'No customers found.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.customers!.length,
            itemBuilder: (context, index) {
              final customer = provider.customers![index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        provider.setVerificationStatus(customer.uId, false);
                      },
                      backgroundColor: (customer.verified ?? false)
                          ? Colors.red
                          : Colors.red[100]!,
                      foregroundColor: Colors.white,
                      icon: Icons.close,
                      label: 'Reject',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        provider.setVerificationStatus(customer.uId, true);
                      },
                      backgroundColor: (customer.verified ?? false)
                          ? Colors.green[100]!
                          : Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: 'Accept',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(customer.userName),
                  subtitle: Text(customer.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.to(CustomerDetailScreen(
                      customer: customer,
                    ));
                    // Get.to(ChangeNotifierProvider(
                    //     create: (BuildContext context) {
                    //       return IncentivePointsProvider();
                    //     },
                    //     child: IncentivePointScreen(customer)));
                  },
                  // Add more customer details as needed
                ),
              );
            },
          );
        },
      ),
    );
  }
}

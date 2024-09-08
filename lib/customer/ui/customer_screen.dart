import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';
import 'package:sanitary_mart_admin/customer/provider/customer_provider.dart';
import 'package:sanitary_mart_admin/customer/ui/customer_detail_screen.dart';

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
    final bool isMediumScreen = ResponsiveWidget.isMediumScreen(context);

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
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.1),
                        Colors.white
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(customer.userName),
                    subtitle: Text(customer.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isMediumScreen
                            ? Container(
                                decoration: BoxDecoration(
                                  color: (customer.verified ?? false)
                                      ? Colors.red
                                      : Colors.red[100]!,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  color: Colors.white,
                                  onPressed: () {},
                                  tooltip: 'Reject',
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(width: 12),
                        isMediumScreen
                            ? Container(
                                decoration: BoxDecoration(
                                  color: (customer.verified ?? false)
                                      ? Colors.green[100]!
                                      : Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.check),
                                  color: Colors.white,
                                  tooltip: 'Accept',
                                  onPressed: () {},
                                ),
                              )
                            : const SizedBox(width: 12),
                        const SizedBox(width: 12),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

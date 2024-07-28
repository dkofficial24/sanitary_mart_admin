import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/incentive_points/ui/incentive_point_provider.dart';
import 'package:sanitary_mart_admin/incentive_points/ui/screen/incentive_point_screen.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  CustomerDetailScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.userName} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('User Name', customer.userName),
              _buildDetailRow('Email', customer.email),
              _buildDetailRow('Phone', customer.phone ?? 'N/A'),
              _buildDetailRow('Address', customer.address ?? 'N/A'),
              _buildBooleanDetailRow('Verified', customer.verified),
              _buildDetailRow(
                'Joined On',
                customer.createdOn != null
                    ? DateFormat('dd MMM yyyy, hh:mm a')
                        .format(customer.createdOn!)
                    : 'N/A',
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(ChangeNotifierProvider(
                        create: (BuildContext context) {
                          return IncentivePointsProvider();
                        },
                        child: IncentivePointScreen(customer)));
                  },
                  child: const Text(
                    'View Incentive Points',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanDetailRow(String title, bool? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  value ?? false ? Icons.check_circle : Icons.cancel,
                  color: value ?? false ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  value ?? false ? 'Yes' : 'No',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

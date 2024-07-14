import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/custom_auto_complete_widget.dart';
import 'package:sanitary_mart_admin/incentive_points/model/incentive_point_model.dart';
import 'package:sanitary_mart_admin/incentive_points/ui/incentive_point_provider.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';

class IncentivePointScreen extends StatefulWidget {
  const IncentivePointScreen(this.customer, {super.key});

  final Customer customer;

  @override
  State<IncentivePointScreen> createState() => _IncentivePointScreenState();
}

class _IncentivePointScreenState extends State<IncentivePointScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchData();
    });

    super.initState();
  }

  void fetchData() async {
    final incentiveProvider =
    Provider.of<IncentivePointsProvider>(context, listen: false);
    incentiveProvider.fetchTotalIncentivePoints(widget.customer.uId);
    incentiveProvider.fetchIncentivePointsHistory(widget.customer.uId);
  }

  void showUpdatePointsBottomSheet(BuildContext context,
      IncentivePointsProvider incentiveProvider, bool isIncrement) {
    TextEditingController pointsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter Points'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final points = double.tryParse(pointsController.text) ?? 0;
                    if (points != 0) {
                      if (isIncrement) {
                        incrementPoint(incentiveProvider, points);
                      } else {
                        decrementPoint(incentiveProvider, points);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isIncrement ? 'Add Points' : 'Reduce Point'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void incrementPoint(
      IncentivePointsProvider incentiveProvider, double points) {
    incentiveProvider.incrementIncentivePoints(widget.customer.uId, points);
  }

  void decrementPoint(
      IncentivePointsProvider incentiveProvider, double points) {
    if (points > incentiveProvider.totalPoints) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot reduce more points than available'),
      ));
      return;
    }
    incentiveProvider.decrementIncentivePoints(widget.customer.uId, points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Incentive Points',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showUpdatePointsBottomSheet(
                context,
                Provider.of<IncentivePointsProvider>(
                  context,
                  listen: false,
                ),
                true),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => showUpdatePointsBottomSheet(
                context,
                Provider.of<IncentivePointsProvider>(context, listen: false),
                false),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Consumer<IncentivePointsProvider>(
              builder: (context, incentiveProvider, child) {
                if (incentiveProvider.providerState == ProviderState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total Points: ${incentiveProvider.totalPoints.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<IncentivePointsProvider>(
                builder: (context, incentiveProvider, child) {
                  if (incentiveProvider.providerState == ProviderState.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (incentiveProvider.incentivePointHistory.isEmpty) {
                    return const Center(child: Text('No Incentive Points History'));
                  }

                  return ListView.separated(
                    itemCount: incentiveProvider.incentivePointHistory.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      IncentivePointInfo point =
                      incentiveProvider.incentivePointHistory[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            'Points: ${point.totalPoints}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 16.0),
                                  Text(
                                    ' Created: ${_formatDate(point.created!)}',
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                        color: _getStatusColor(
                                            point.redeemStatus)),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: CustomAutoCompleteWidget<String>(
                                      label: '',
                                      initailValue: point.redeemStatus.name,
                                      options: RedeemStatus.values
                                          .map((e) => e.name.toString())
                                          .toList(),
                                      onSuggestionSelected:
                                          (String? redeemStatus) {
                                        incentivePointStatusUpdate(
                                            redeemStatus, incentiveProvider, point);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Icon(
                                      getStatusIcon(point.redeemStatus),
                                    size: 16.0,
                                      color:
                                          _getStatusColor(point.redeemStatus)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void incentivePointStatusUpdate(
      String? redeemStatus,
      IncentivePointsProvider incentiveProvider,
      IncentivePointInfo point,
      ) {
    if (redeemStatus != null) {
      incentiveProvider.updateIncentiveRedeemStatus(
        widget.customer.uId,
        IncentivePointInfo.parseStatus(redeemStatus),
        point.id!,
      );
    }
  }

  String _formatDate(int millisecondsSinceEpoch) {
    return AppUtil.convertTimestampInDate(millisecondsSinceEpoch);
  }

  IconData getStatusIcon(RedeemStatus status) {
    switch (status) {
      case RedeemStatus.accepted:
        return Icons.check_circle_outline;
      case RedeemStatus.rejected:
        return Icons.close_outlined;
      case RedeemStatus.processing:
        return Icons.access_time_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getStatusColor(RedeemStatus status) {
    switch (status) {
      case RedeemStatus.accepted:
        return Colors.green;
      case RedeemStatus.processing:
        return Colors.orange;
      case RedeemStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

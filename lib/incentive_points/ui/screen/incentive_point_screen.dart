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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incentive Points History'),
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

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total Points: ${incentiveProvider.totalPoints}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                updatePoints(incentiveProvider, -1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                updatePoints(incentiveProvider, 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
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
                                  const Icon(Icons.calendar_today_outlined, size: 16.0),
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
                                        color: point.redeemStatus == 'Redeemed'
                                            ? Colors.green
                                            : Colors.orange),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: CustomAutoCompleteWidget<String>(
                                      label: '',
                                      initailValue: point.redeemStatus.name,
                                      options: RedeemStatus.values
                                          .map((e) => e.name.toString())
                                          .toList(),
                                      onSuggestionSelected: (String? redeemStatus) {
                                        incentivePointStatusUpdate(
                                            redeemStatus, incentiveProvider, point);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Icon(
                                    point.redeemStatus == 'Redeemed'
                                        ? Icons.check_circle_outline
                                        : Icons.access_time_outlined,
                                    size: 16.0,
                                    color: point.redeemStatus == 'Redeemed'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
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

  void updatePoints(IncentivePointsProvider incentiveProvider, int change) {
    final newPoints = incentiveProvider.totalPoints + change;
    if (newPoints >= 0) {
      incentiveProvider.updateIncentivePoints(widget.customer.uId, change.toDouble());
    }
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/payment/model/account_info_model.dart';
import 'package:sanitary_mart_admin/payment/provider/payment_info_provider.dart';
import 'package:sanitary_mart_admin/payment/ui/input_payment_screen.dart';

class PaymentInfoScreen extends StatefulWidget {
  const PaymentInfoScreen({super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchPaymentAccountInfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PaymentInfoProvider>(
        builder: (context, provider, child) {
          Widget widget = const SizedBox();
          if (provider.providerState == ProviderState.loading) {
            widget = const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.providerState == ProviderState.error) {
            widget = Center(
              child: ErrorRetryWidget(
                onRetry: () {
                  fetchPaymentAccountInfo();
                },
              ),
            );
          } else if (provider.paymentInfoList.isEmpty) {
            widget = const Center(
              child: Text(
                'No Payment details available.\nUse + icon to add it',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            widget = Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: provider.paymentInfoList.length,
                itemBuilder: (context, index) {
                  PaymentInfo paymentInfo = provider.paymentInfoList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment method',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('UPI'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: NetworkImageWidget(
                              paymentInfo.qrCodeUrl ?? '',
                              imgHeight: Get.height * 0.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(paymentInfo.accountHolderName ??
                                  'Not Available'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'UPI Id',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(paymentInfo.upiId ?? 'Not Available'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                      context, paymentInfo);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Get.to(InputPaymentScreen(
                                      paymentInfo: paymentInfo));
                                  fetchPaymentAccountInfo();
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
            );
          }

          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Payment info',
            ),
            floatingActionButton:
                provider.providerState != ProviderState.loading
                    ? FloatingActionButton(
                        onPressed: () async {
                          await Get.to(InputPaymentScreen(paymentInfo: null));
                          fetchPaymentAccountInfo();
                        },
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox(),
            body: widget,
          );
        },
      ),
    );
  }

  Future fetchPaymentAccountInfo() async {
    Provider.of<PaymentInfoProvider>(context, listen: false).fetchPaymentInfo();
  }

  void showDeleteConfirmationDialog(
      BuildContext context, PaymentInfo paymentInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Info'),
        content:
            const Text('Are you sure you want to delete this payment info?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<PaymentInfoProvider>(context, listen: false)
                  .deletePaymentInfo(paymentInfo.id!);
              fetchPaymentAccountInfo();
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

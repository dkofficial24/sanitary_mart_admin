import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
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
    return SafeArea(child: Consumer<PaymentInfoProvider>(
      builder: (context, provider, child) {
        Widget widget = const SizedBox();
        if (provider.providerState == ProviderState.loading) {
          widget = const Center(
            child: CircularProgressIndicator(),
          );
        } else if (provider.providerState == ProviderState.error) {
          widget = Center(child: ErrorRetryWidget(
            onRetry: () {
              fetchPaymentAccountInfo();
            },
          ));
        } else if (provider.paymentInfo == null) {
          widget = const Center(
            child: Text(
              'No Payment details available.\nUse + icon to add it',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          widget = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment method', style: TextStyle(fontWeight: FontWeight.bold)), // Bold label
                    Text('UPI'), // Assuming UPI is the current method
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkImageWidget(
                    provider.paymentInfo?.qrCodeUrl ?? '',
                    imgHeight: Get.height * 0.4,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)), // Bold label
                    Text(provider.paymentInfo?.accountHolderName ?? 'Not Available'),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('UPI Id', style: TextStyle(fontWeight: FontWeight.bold)), // Bold label
                    Text(provider.paymentInfo?.upiId ?? 'Not Available'),
                  ],
                ),
                // Add additional info rows here (if applicable)
              ],
            ),
          );
        }

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Payment info',
          ),
          floatingActionButton: provider.providerState != ProviderState.loading
              ? FloatingActionButton(
              onPressed: () async {
                await Get.to(
                    InputPaymentScreen(paymentInfo: provider.paymentInfo));
                fetchPaymentAccountInfo();
              },
              child: provider.paymentInfo == null
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit))
              : const SizedBox(),
          body: widget,
        );
      },
    ));
  }

  Future fetchPaymentAccountInfo() async {
    Provider.of<PaymentInfoProvider>(context, listen: false).fetchPaymentInfo();
  }
}

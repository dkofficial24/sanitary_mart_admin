import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/payment/model/account_info_model.dart';
import 'package:sanitary_mart_admin/payment/provider/payment_info_provider.dart';

class InputPaymentScreen extends StatefulWidget {
  final PaymentInfo? paymentInfo;

  const InputPaymentScreen({super.key, this.paymentInfo});

  @override
  _InputPaymentScreenState createState() => _InputPaymentScreenState();
}

class _InputPaymentScreenState extends State<InputPaymentScreen> {
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? file;

  @override
  void initState() {
    upiIdController.text = widget.paymentInfo?.upiId ?? '';
    ownerNameController.text = widget.paymentInfo?.accountHolderName ?? '';

    super.initState();
  }

  Future<void> pickImage(ImageSource imageSource) async {
    XFile? xFile = await ImagePicker().pickImage(source: imageSource);
    if (xFile != null) {
      file = File(xFile.path);
    }
    setState(() {});
  }

  String? validateUPIId(String? value) {
    if (value == null || value.isEmpty) {
      return 'UPI ID cannot be empty';
    }
    // Add more complex UPI ID validation if needed
    return null;
  }

  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner Name cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment info'),
      ),
      body: Consumer<PaymentInfoProvider>(
        builder: (context, provider, child) {
          if (provider.providerState == ProviderState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.providerState == ProviderState.error) {
            return ErrorRetryWidget(onRetry: () {
              addPaymentInfo(context);
            });
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                      ),
                      validator: validateUPIId,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                      ),
                      validator: validateOwnerName,
                    ),
                    buildQrWidget(provider),
                    const SizedBox(height: 16.0),
                    if (file == null) const Text('Upload QR Code'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () async {
                              pickImage(ImageSource.camera);
                            },
                            icon: const Icon(Icons.camera)),
                        IconButton(
                            onPressed: () async {
                              pickImage(ImageSource.gallery);
                            },
                            icon: const Icon(Icons.image)),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.paymentInfo != null) {
                            updatePaymentInfo(context);
                          } else {
                            addPaymentInfo(context);
                          }
                        }
                      },
                      child: Text(
                          widget.paymentInfo != null ? 'Update' : 'Submit'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future addPaymentInfo(BuildContext context) async {
    if (file == null) {
      Get.snackbar('Error', 'Please select a QR code image');
      return;
    } else {
      final provider = Provider.of<PaymentInfoProvider>(context, listen: false);
      String? imgUrl = await provider.uploadQRCode(file!.path);
      if (imgUrl != null) {
        provider.addPaymentInfo(PaymentInfo(
            upiId: upiIdController.text,
            accountHolderName: ownerNameController.text,
            qrCodeUrl: imgUrl));
      }
    }
  }

  Future updatePaymentInfo(BuildContext context) async {
    String? imgUrl;
    final provider = Provider.of<PaymentInfoProvider>(context, listen: false);
    if (file != null) {
      imgUrl = await provider.uploadQRCode(file!.path);
    } else {
      imgUrl = widget.paymentInfo!.qrCodeUrl;
    }
    if (imgUrl != null) {
      provider.updatePaymentInfo(PaymentInfo(
        id: widget.paymentInfo!.id!,
        upiId: upiIdController.text,
        accountHolderName: ownerNameController.text,
        qrCodeUrl: imgUrl,
      ));
    }
  }

  Widget buildQrWidget(PaymentInfoProvider provider) {
    if (file != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Image.file(
          file!,
          height: Get.height * 0.4,
        ),
      );
    } else {
      return NetworkImageWidget(
        widget.paymentInfo?.qrCodeUrl ?? '',
        imgHeight: Get.height * 0.4,
      );
    }
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/payment/model/account_info_model.dart';
import 'package:sanitary_mart_admin/payment/service/payment_firebase_service.dart';

class PaymentInfoProvider extends ChangeNotifier {
  PaymentInfo? paymentInfo;
  ProviderState providerState = ProviderState.idle;
  bool isUploading = false;

  Future fetchPaymentInfo() async {
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      PaymentFirebaseService adminService = Get.find<PaymentFirebaseService>();
      paymentInfo = await adminService.fetchPaymentInfo();
      providerState = ProviderState.idle;
      notifyListeners();
    } catch (e) {
      providerState = ProviderState.error;
      notifyListeners();
    }
  }

  Future updatePaymentInfo(PaymentInfo paymentInfo) async {
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      PaymentFirebaseService adminService = Get.find<PaymentFirebaseService>();
      adminService.updatePaymentInfo(paymentInfo);
      providerState = ProviderState.idle;
      notifyListeners();
    } catch (e) {
      providerState = ProviderState.error;
      AppUtil.showToast('Unable to update payment info');
      notifyListeners();
    }
  }

  Future addPaymentInfo(PaymentInfo paymentInfo) async {
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      PaymentFirebaseService adminService = Get.find<PaymentFirebaseService>();
      String? url = await uploadQRCode(paymentInfo.qrCodeUrl);
      if (url != null) {
        paymentInfo.qrCodeUrl = url;
      }
      adminService.addPaymentInfo(paymentInfo);
      providerState = ProviderState.idle;
      notifyListeners();
      AppUtil.showToast('Payment details saved');
      Get.back();
    } catch (e) {
      AppUtil.showToast('Unable to add payment info');
      providerState = ProviderState.error;
      notifyListeners();
    }
  }

  Future<String?> uploadQRCode(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      notifyListeners();
      providerState = ProviderState.loading;
      isUploading = true;
      notifyListeners();
      File file = await AppUtil.compressImage(File(imagePath));
      String imageUrl = await Get.find<PaymentFirebaseService>().uploadQRCode(file.path);
      isUploading = false;
      providerState = ProviderState.idle;
      return imageUrl;
    } catch (e) {
      isUploading = false;
      providerState = ProviderState.error;
      AppUtil.showToast('Failed to upload QRCode Image');
      return null;
    } finally {
      notifyListeners();
    }
  }
}

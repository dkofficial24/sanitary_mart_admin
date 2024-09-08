import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/auth/screen/login_screen.dart';
import 'package:sanitary_mart_admin/auth/screen/otp_screen.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';
import 'package:sanitary_mart_admin/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart_admin/util/storage_helper.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool isLoading = false;
  final StorageHelper storageHelper;
  bool isLoggedIn = false;
  int? resendToken;

  AuthenticationProvider(this.storageHelper);

  Future login(String phoneNumber, {bool resend = false}) async {
    try {
      showLoader();
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            hideLoader();
          },
          verificationFailed: (FirebaseAuthException e) {
            Get.snackbar(AppText.verificationFailedAlert, e.message.toString());
            hideLoader();
          },
          codeSent: (String verificationId, int? resendToken) {
            this.resendToken = resendToken;
            hideLoader();
            if (!resend) {
              Get.to(OTPScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              ));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            hideLoader();
          },
          forceResendingToken: resend ? resendToken : null);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(AppText.error, e.message.toString());
      hideLoader();
    }
  }

  void hideLoader() {
    isLoading = false;
    notifyListeners();
  }

  Future verifyOTP({
    required String otp,
    required String verificationId,
  }) async {
    try {
      showLoader();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      UserCredential cred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String? uid = cred.user?.uid;
      if (uid != null) {
        storageHelper.saveUserId(uid);
      }
      hideLoader();

      Get.offAll(DashboardScreen());
    } on FirebaseAuthException catch (e) {
      hideLoader();
      Get.snackbar(AppText.error, e.message.toString());
    }
  }

  Future loadLoggedStatus() async {
    showLoader();
    String? uid = await storageHelper.getUserId();
    isLoggedIn = uid != null;
    hideLoader();
  }

  void showLoader() {
    isLoading = true;
    notifyListeners();
  }

  Future logout() async {
    await storageHelper.clearUserId();
    Get.off(LoginScreen());
  }
}

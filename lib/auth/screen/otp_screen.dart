import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/auth/provider/auth_provider.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';
import 'package:sanitary_mart_admin/core/widget/app_logo.dart';
import 'package:sanitary_mart_admin/core/widget/custom_button.dart';
import 'package:sanitary_mart_admin/core/widget/custom_loader.dart';
import 'package:sanitary_mart_admin/core/widget/otp_widget.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    required this.verificationId,
    required this.phoneNumber,
    super.key,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          return CustomLoader(
            showLoader: authProvider.isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(AppText.enterOtp),
                    const SizedBox(
                      height: 16,
                    ),
                    OtpWidget(otpController: otpController),
                    const SizedBox(
                      height: 16,
                    ),
                    TextButton(
                      onPressed: () {
                        otpController.clear();
                        authProvider.login(
                          widget.phoneNumber,
                          resend: true,
                        );
                      },
                      child: const Text(AppText.didNotGetOtp),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomButton(
                        onPressed: () {
                          String otp = otpController.text;
                          if (otp.length == 6) {
                            final authProvider =
                                Provider.of<AuthenticationProvider>(
                              context,
                              listen: false,
                            );
                            authProvider.verifyOTP(
                              otp: otp,
                              verificationId: widget.verificationId,
                            );
                          }
                        },
                        name: AppText.getStarted)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

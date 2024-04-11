import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';

class OtpWidget extends StatelessWidget {
  const OtpWidget({
    super.key,
    required this.otpController,
  });

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return Pinput(
        controller: otpController,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        length: 6,
        defaultPinTheme: PinTheme(
          width: 56,
          height: 56,
          textStyle: TextStyle(
              fontSize: 20,
              color: AppColor.fieldTextColor,
              fontWeight: FontWeight.w600),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.fieldBorderColor),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onCompleted: (pin) {});
  }
}

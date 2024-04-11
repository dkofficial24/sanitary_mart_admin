import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.name,
    this.onPressed,
    super.key,
  });

  final String name;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColor.buttonBackground,
            ),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              color: AppColor.buttonTextColor,
            ),
          )),
    );
  }
}

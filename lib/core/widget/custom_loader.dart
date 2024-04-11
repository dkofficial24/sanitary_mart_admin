import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';


class CustomLoader extends StatelessWidget {
  const CustomLoader({
    required this.child,
    this.showLoader = false,
    super.key,
  });

  final Widget child;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (showLoader)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColor.loaderColor,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
    ]);
  }
}

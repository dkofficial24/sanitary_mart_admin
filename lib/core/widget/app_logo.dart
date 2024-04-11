import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/core/constant/app_assets.dart';



class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Image.asset(
      AppAssets.logo,
      height: size.width * 0.4,
      width: size.width * 0.4,
    );
  }
}

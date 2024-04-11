import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/auth/provider/auth_provider.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';
import 'package:sanitary_mart_admin/core/widget/app_logo.dart';
import 'package:sanitary_mart_admin/core/widget/custom_button.dart';
import 'package:sanitary_mart_admin/core/widget/custom_loader.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AuthenticationProvider>(
          builder: (context, authProvider, child) {
            return CustomLoader(
              showLoader: authProvider.isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(),
                    const SizedBox(
                      height: 16,
                    ),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return AppText.invalidPhoneNo;
                          }
                          return null;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColor.fieldTextColor),
                        decoration: InputDecoration(
                          hintText: AppText.phoneFieldHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomButton(
                      name: AppText.next,
                      onPressed: () {
                        login(context);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void login(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      String phoneNumber = phoneController.text;
      phoneNumber = '+91$phoneNumber';
      final authProvide =
          Provider.of<AuthenticationProvider>(context, listen: false);
      authProvide.login(phoneNumber);
    }
  }
}

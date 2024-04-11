import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/ui/widget/add_edit_brand_widget.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/widget/custom_app_bar.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  AddBrandScreenState createState() => AddBrandScreenState();
}

class AddBrandScreenState extends State<AddBrandScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Add Brand',
          ),
          body: AddEditBrandWidget(
            actionButtonName: 'Add Brand',
            onAction: (category) async {
              addBrand(context, category);
            },
          ),
        );
      },
    );
  }

  void addBrand(BuildContext context, Brand brand) async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    await brandProvider.addBrand(brand);
    brandProvider.fetchBrands();
    Get.back();
  }
}

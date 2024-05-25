import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/ui/widget/add_edit_brand_widget.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/widget/custom_app_bar.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({this.categoryId, super.key});

  final String? categoryId;

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
            onAction: (brand) async {
              addBrand(context, brand);
            },
          ),
        );
      },
    );
  }

  Future addBrand(BuildContext context, Brand brand) async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    if (widget.categoryId != null) {
      await brandProvider.addBrand(brand, categoryId: widget.categoryId);
      await brandProvider.fetchBrandsByCategory(widget.categoryId!);
    } else {
      await brandProvider.addBrand(brand);
      await brandProvider.fetchBrands();
    }
    Get.back();
  }
}

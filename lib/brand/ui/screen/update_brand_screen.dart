import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/ui/widget/add_edit_brand_widget.dart';
import 'package:sanitary_mart_admin/core/core.dart';


class UpdateBrandScreen extends StatefulWidget {
  const UpdateBrandScreen(this.brand, {super.key});

  final Brand brand;

  @override
  UpdateBrandScreenState createState() => UpdateBrandScreenState();
}

class UpdateBrandScreenState extends State<UpdateBrandScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Update Brand',
          ),
          body: AddEditBrandWidget(
            actionButtonName: 'Update Brand',
            brand: widget.brand,
            onAction: (brand) async {
              brand.id = widget.brand.id;
              if (brand.imagePath != widget.brand.imagePath) {
                BrandProvider brandProvider = getBrandProvider(context);
                String? newImagePath = await brandProvider
                    .uploadBrandImage(brand.imagePath);
                brand.imagePath = newImagePath;
              }
              if (mounted) {
                updateBrand(context, brand);
              }
            },
          ),
        );
      },
    );
  }

  BrandProvider getBrandProvider(BuildContext context) {
    final brandProvider =
    Provider.of<BrandProvider>(context, listen: false);
    return brandProvider;
  }

  void updateBrand(BuildContext context, Brand brand) async {
    BrandProvider brandProvider = getBrandProvider(context);
    await brandProvider.updateBrand(brand);
    brandProvider.fetchBrands();
    Get.back();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/add_brand_screen.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/update_brand_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/core/widget/grid_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart_admin/product/ui/screen/product_list_screen_new.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen(this.categoryId, {super.key});

  final String categoryId;

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchBrandsByCategory();
    });
    super.initState();
  }

  void fetchBrandsByCategory() {
    Provider.of<BrandProvider>(
      context,
      listen: false,
    ).getBrandsByCategory(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Brands',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddBrandScreen(categoryId: widget.categoryId));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<BrandProvider>(
          builder: (context, provider, child) {
            if (provider.state == ProviderState.loading) {
              return const ShimmerGridListWidget();
            } else if (provider.state == ProviderState.error) {
              return ErrorRetryWidget(
                onRetry: () {
                  fetchBrandsByCategory();
                },
              );
            }

            if (provider.brandList.isEmpty) {
              return const Center(
                child: Text('No brands available for this category'),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: provider.brandList.length,
              itemBuilder: (context, index) {
                final brand = provider.brandList[index];
                return GridItemWidget(
                  name: brand.name,
                  image: brand.imagePath ?? '',
                  onItemTap: () {
                    Get.to(ProductListScreenNew(
                      categoryId: widget.categoryId,
                      brandId: brand.id!,
                      brandName: brand.name,
                    ));
                  },
                  deleteCallback: () {
                    showDeleteBrandDialog(context, brand);
                  },
                  editCallback: () {
                    _editBrand(context, brand, widget.categoryId);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _editBrand(BuildContext context, Brand brand, String categoryId) {
    Get.to(UpdateBrandScreen(
      brand,
      categoryId: categoryId,
    ));
  }

  void showDeleteBrandDialog(BuildContext context, Brand category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert '),
        content: Text("Delete ${category.name} Brand ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () async {
                await deleteBrand(context, category);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<void> deleteBrand(BuildContext context, Brand category) async {
    await Provider.of<BrandProvider>(context, listen: false)
        .deleteBrand(category.id!);
  }
}

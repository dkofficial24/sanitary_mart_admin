import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/add_brand_screen.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/update_brand_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/list_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<BrandListScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchBrands();
    });
    super.initState();
  }

  void fetchBrands() {
    Provider.of<BrandProvider>(context, listen: false).fetchBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Brands',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddBrandScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: ResponsiveWidget(
        largeScreen: Consumer<BrandProvider>(
          builder: (BuildContext context, provider, Widget? child) {
            if (provider.state == ProviderState.loading) {
              return const ListViewShimmer();
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: ListView.builder(
                // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //   crossAxisCount:3,
                //   childAspectRatio: 3,
                //   crossAxisSpacing: 10,
                //   mainAxisSpacing: 10,
                // ),
                itemCount: provider.brandList.length,
                itemBuilder: (context, index) {
                  final brand = provider.brandList[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.branding_watermark,
                              color: Colors.blueAccent),
                          const SizedBox(width: 16.0),

                          Expanded(
                            flex: 2,
                            child: Text(
                              brand.name,
                              style: const TextStyle(
                                fontSize: 18,
                                // Slightly larger font for better visibility
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Spacing between text and buttons
                          const SizedBox(width: 16.0),

                          // Action Buttons
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Delete Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    // Light red background
                                    shape: BoxShape.circle, // Circular shape
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red, // Icon color
                                    onPressed: () =>
                                        _deleteBrand(context, brand),
                                    tooltip: 'Delete Brand',
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                // Spacing between buttons

                                // Edit Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    // Light blue background
                                    shape: BoxShape.circle, // Circular shape
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue, // Icon color
                                    onPressed: () => _editBrand(context, brand),
                                    tooltip: 'Edit Brand',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        smallScreen: Consumer<BrandProvider>(
          builder:
              (BuildContext context, BrandProvider provider, Widget? child) {
            if (provider.state == ProviderState.loading) {
              return const ListViewShimmer();
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: provider.brandList.length,
              itemBuilder: (context, index) {
                final brand = provider.brandList[index];
                return ListItemWidget(
                    name: brand.name,
                    imagePath: brand.imagePath,
                    onDeleteCallback: () {
                      _deleteBrand(context, brand);
                    },
                    onEditCallback: () {
                      _editBrand(context, brand);
                    });
              },
            );
          },
        ),
      ),
    );
  }

  void _editBrand(BuildContext context, Brand brand) {
    Get.to(UpdateBrandScreen(brand));
  }

  void _deleteBrand(BuildContext context, Brand category) {
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

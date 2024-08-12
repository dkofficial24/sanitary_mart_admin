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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveWidget.isMediumScreen(context) ? 3 : 5,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.brandList.length,
                itemBuilder: (context, index) {
                  final brand = provider.brandList[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Uncomment and use this if category has an image
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(8),
                          //   child: SizedBox(
                          //       width: 30, height: 30,
                          //       child: NetworkImageWidget(category.imagePath ?? '')),
                          // ),
                          Expanded(
                            child: Text(
                              brand.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteBrand(context, brand),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editBrand(context, brand),
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
                final category = provider.brandList[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _deleteBrand(context, category);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editBrand(context, category),
                    ),
                  ),
                );
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

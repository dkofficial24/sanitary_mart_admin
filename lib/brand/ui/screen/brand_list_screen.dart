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
      body: Consumer<BrandProvider>(
        builder: (BuildContext context, BrandProvider provider, Widget? child) {
          if (provider.state == ProviderState.loading) {
            return const ListViewShimmer();
          }
          return ListView.builder(
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

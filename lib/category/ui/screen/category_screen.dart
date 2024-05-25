import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/brand_screen.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/ui/screen/add_category_screen.dart';
import 'package:sanitary_mart_admin/category/ui/screen/update_category_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/core/widget/grid_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/shimmer_grid_list_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'category_tab');
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchCategories();
    });
    super.initState();
  }

  void fetchCategories() {
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Categories',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddCategoryScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            if (provider.state == ProviderState.loading) {
              return const ShimmerGridListWidget();
            } else if (provider.state == ProviderState.error) {
              return ErrorRetryWidget(
                onRetry: () {
                  fetchCategories();
                },
              );
            }

            if (provider.categoryList.isEmpty) {
              return const Center(
                child: Text('No category available'),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: provider.categoryList.length,
              itemBuilder: (context, index) {
                final category = provider.categoryList[index];
                return GridItemWidget(
                  name: category.name,
                  image: category.imagePath ?? '',
                  onItemTap: () {
                    Get.to(BrandScreen(category.id!));
                  },
                  editCallback: () {
                    _editCategory(category);
                  },
                  deleteCallback: () {
                    showDeleteCategoryDialog(context, category);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void showDeleteCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert '),
        content: Text("Delete ${category.name} category ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () async {
                await deleteCategory(context, category.id!);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  void _editCategory(Category category) {
    Get.to(UpdateCategoryScreen(category));
  }

  Future<void> deleteCategory(BuildContext context, String categoryId) async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .deleteCategory(categoryId);
  }
}

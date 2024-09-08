import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/ui/screen/brand_screen.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/ui/screen/add_category_screen.dart';
import 'package:sanitary_mart_admin/category/ui/screen/update_category_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/list_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/responsive_widget.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
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
      body: ResponsiveWidget(
        largeScreen: Consumer<CategoryProvider>(
          builder:
              (BuildContext context, CategoryProvider provider, Widget? child) {
            if (provider.state == ProviderState.loading) {
              return const ListViewShimmer();
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: ListView.builder(
                itemCount: provider.categoryList.length,
                itemBuilder: (context, index) {
                  final category = provider.categoryList[index];
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
                          const Icon(
                            Icons.category,
                            color: Colors.blueAccent,
                          ),

                          const SizedBox(width: 16.0),

                          Expanded(
                            flex: 2,
                            child: Text(
                              category.name,
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
                                        _deleteCategory(context, category),
                                    tooltip: 'Delete Category',
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
                                    onPressed: () =>
                                        _editCategory(context, category),
                                    tooltip: 'Edit Category',
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
        smallScreen: Consumer<CategoryProvider>(
          builder:
              (BuildContext context, CategoryProvider provider, Widget? child) {
            if (provider.state == ProviderState.loading) {
              return const ListViewShimmer();
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: provider.categoryList.length,
              itemBuilder: (context, index) {
                final category = provider.categoryList[index];
                return ListItemWidget(
                  imagePath: category.imagePath,
                  name: category.name,onDeleteCallback: (){
                  _deleteCategory(context, category);
                },onTapCallback: (){
                  Get.to(BrandScreen(category.id!));
                },
                onEditCallback: (){
                  _editCategory(context, category);
                },
                );

              },
            );
          },
        ),
      ),
    );
  }

  void _editCategory(BuildContext context, Category category) {
    Get.to(UpdateCategoryScreen(category));
  }

  void _deleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert '),
        content: Text("Delete ${category.name} Category ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () async {
                await deleteCategory(context, category);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<void> deleteCategory(BuildContext context, Category category) async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .deleteCategory(category.id!);
  }
}

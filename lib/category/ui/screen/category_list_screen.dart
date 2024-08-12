import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/ui/screen/add_category_screen.dart';
import 'package:sanitary_mart_admin/category/ui/screen/update_category_screen.dart';
import 'package:sanitary_mart_admin/core/core.dart';
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveWidget.isMediumScreen(context) ? 3 : 5,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.categoryList.length,
                itemBuilder: (context, index) {
                  final category = provider.categoryList[index];
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
                              category.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteCategory(context, category),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editCategory(context, category),
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
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _deleteCategory(context, category);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    // leading: ClipRRect(
                    //   borderRadius: BorderRadius.circular(8),
                    //   child: SizedBox(
                    //       width: 30,height: 30,
                    //       child: NetworkImageWidget(category.imagePath ?? '')),
                    // ),
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editCategory(context, category),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/ui/widget/add_edit_category_widget.dart';
import 'package:sanitary_mart_admin/core/core.dart';

class UpdateCategoryScreen extends StatefulWidget {
  const UpdateCategoryScreen(this.category, {super.key});

  final Category category;

  @override
  UpdateCategoryScreenState createState() => UpdateCategoryScreenState();
}

class UpdateCategoryScreenState extends State<UpdateCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Update Category',
          ),
          body: AddEditCategoryWidget(
            actionButtonName: 'Update Category',
            category: widget.category,
            onAction: (category) async {
              category.id = widget.category.id;
              if (category.imagePath != widget.category.imagePath) {
                CategoryProvider categoryProvider = getCategoryProvider(context);
                String? newImagePath = await categoryProvider
                    .uploadCategoryImage(category.imagePath);
                category.imagePath = newImagePath;
              }
              if (mounted) {
                updateCategory(context, category);
              }
            },
          ),
        );
      },
    );
  }

  CategoryProvider getCategoryProvider(BuildContext context) {
     final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    return categoryProvider;
  }

  void updateCategory(BuildContext context, Category category) async {
    CategoryProvider categoryProvider = getCategoryProvider(context);
    await categoryProvider.updateCategory(category);
    categoryProvider.fetchCategories();
    Get.back();
  }
}

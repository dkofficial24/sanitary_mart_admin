import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/ui/widget/add_edit_category_widget.dart';
import 'package:sanitary_mart_admin/core/core.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  AddCategoryScreenState createState() => AddCategoryScreenState();
}

class AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Add Category',
          ),
          body: AddEditCategoryWidget(
            actionButtonName: 'Add Category',
            onAction: (category) async {
              addCategory(context, category);
            },
          ),
        );
      },
    );
  }

  void addCategory(BuildContext context, Category category) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.addCategory(category);
    categoryProvider.fetchCategories();
    Get.back();
  }
}

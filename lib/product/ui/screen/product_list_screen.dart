import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/ui/screen/add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Brand? selectedBrand;
  Category? selectedCategory;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Products',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddEditProductScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<CategoryProvider>(
                builder: (BuildContext context,
                    CategoryProvider categoryProvider, Widget? child) {
                  return DropdownButtonFormField<Category>(
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                    ),
                    items: categoryProvider.categoryList.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        onTap: () {},
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (category) {
                      selectedCategory = category;
                      selectedBrand = null;
                      Provider.of<ProductProvider>(context, listen: false)
                          .clearProducts();
                      Provider.of<BrandProvider>(context, listen: false)
                          .fetchBrandsByCategory(selectedCategory!.id!);
                      setState(() {});
                      FirebaseAnalytics.instance
                          .logEvent(name: 'drop_down_select_category');
                    },
                  );
                },
              ),
              // Brand Dropdown (you need to implement BrandProvider)
              Consumer<BrandProvider>(builder: (BuildContext context,
                  BrandProvider brandProvider, Widget? child) {
                if(brandProvider.brandList.isEmpty)return const SizedBox();
                return DropdownButtonFormField<Brand>(
                  decoration: const InputDecoration(
                    labelText: 'Select Brand',
                  ),
                  items: brandProvider.brandList.map((brand) {
                    return DropdownMenuItem<Brand>(
                      value: brand,
                      child: Text(brand.name),
                    );
                  }).toList(),
                  onChanged: (brand) {
                    selectedBrand = brand;
                    setState(() {});
                    fetchProduct(selectedCategory?.id, selectedBrand?.id);
                    FirebaseAnalytics.instance
                        .logEvent(name: 'drop_down_select_brand');
                  },
                );
              }),
              const SizedBox(
                height: 16,
              ),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: provider.products.length,
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      );
                    },
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                deleteProductDialog(context, product);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                AppUtil.showToast('Under development');
                                // Get.to(AddEditProductScreen(
                                //   initialProduct: product,
                                // ));
                              },
                              backgroundColor: Colors.black26,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                                width: 100,
                                height: 100,
                                child: NetworkImageWidget(product.image)),
                          ),
                          // Product image
                          title: Text(product.name),
                          // Product name
                          //  subtitle:
                          //    Text('${product.categoryId} - ${product.brandId}'),
                          trailing: Text(
                              '\$${product.price.toStringAsFixed(2)}'), // Product price
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future fetchProduct(String? categoryId, String? brandId) async {
    if (categoryId == null || brandId == null) return;
    Provider.of<ProductProvider>(context, listen: false)
        .fetchProductsByCategoryBrand(categoryId, brandId);
  }

  void deleteProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert '),
        content: Text("Delete ${product.name} product ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
              onPressed: () async {
                await deleteProduct(context, product);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<void> deleteProduct(BuildContext context, Product product) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .deleteProduct(product.id!);
  }
}

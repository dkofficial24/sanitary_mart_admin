import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/core/widget/product_list_view_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/ui/screen/add_edit_product_screen.dart';
import 'package:sanitary_mart_admin/product/ui/screen/product_detail_screen.dart';

class ProductListScreenNew extends StatefulWidget {
  const ProductListScreenNew({
    required this.categoryId,
    required this.brandId,
    required this.brandName,
    Key? key,
  }) : super(key: key);

  final String categoryId;
  final String brandId;
  final String brandName;

  @override
  _ProductListScreenNewState createState() => _ProductListScreenNewState();
}

class _ProductListScreenNewState extends State<ProductListScreenNew> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchAllProducts();
    });
    super.initState();
  }

  void fetchAllProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchAllProducts(
      widget.categoryId,
      widget.brandId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.brandName,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddEditProductScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.state == ProviderState.loading) {
              return const ShimmerGridListWidget();
            } else if (provider.state == ProviderState.error) {
              return ErrorRetryWidget(
                onRetry: () {
                  fetchAllProducts();
                },
              );
            }

            if (provider.products.isEmpty) {
              return const Center(
                child: Text('No products available under this brand'),
              );
            }

            return ListView.builder(
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final Product product = provider.products[index];

                return ProductListViewItemWidget(
                  product: product,
                  onPressed: (context)async{
                    await Get.to(AddEditProductScreen(
                      initialProduct: product,
                    ));
                    fetchAllProducts();
                  },
                );
              },
            );
          },
        ),
      ),
    );
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

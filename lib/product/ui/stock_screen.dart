import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/core/widget/product_list_view_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';

class ProductStockScreen extends StatefulWidget {
  const ProductStockScreen({super.key});

  @override
  State<ProductStockScreen> createState() => _ProductStockScreenState();
}

class _ProductStockScreenState extends State<ProductStockScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchAllProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Stock',
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
                  //fetchAllProducts();
                },
              );
            }

            if (provider.products.isEmpty) {
              return const Center(
                child: Text('No products available'),
              );
            }

            return ListView.builder(
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final Product product = provider.products[index];

                return ProductListViewItemWidget(
                  product: product,
                  onPressed: (context) async {
                    // await Get.to(AddEditProductScreen(
                    //   initialProduct: product,
                    // ));
                    // fetchAllProducts();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void fetchAllProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchAllProducts();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/core/widget/error_retry_widget.dart';
import 'package:sanitary_mart_admin/core/widget/product_list_view_item_widget.dart';
import 'package:sanitary_mart_admin/core/widget/shimmer_grid_list_widget.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/ui/screen/add_edit_product_screen.dart';

class ProductStockScreen extends StatefulWidget {
  const ProductStockScreen({super.key});

  @override
  State<ProductStockScreen> createState() => _ProductStockScreenState();
}

class _ProductStockScreenState extends State<ProductStockScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchAllProducts();
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchAllProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Stock',
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ProductProvider>().isAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () {
              context.read<ProductProvider>().toggleSortOrder();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<ProductProvider>()
                                .updateSearchQuery('');
                          },
                        ),
                      ),
                      onChanged: (query) {
                        context
                            .read<ProductProvider>()
                            .updateSearchQuery(query);
                      },
                    ),
                  ),
                  body(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget body(ProductProvider provider) {
    if (provider.state == ProviderState.loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: ShimmerGridListWidget(),
      );
    } else if (provider.state == ProviderState.error) {
      return ErrorRetryWidget(
        onRetry: fetchAllProducts,
      );
    }

    if (provider.filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products available'),
      );
    }
    return Column(
      children: [
        ListView.builder(
          itemCount: provider.filteredProducts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final product = provider.filteredProducts[index];
            return ProductListViewItemWidget(
              product: product,
              onPressed: (context) async {
                await Get.to(AddEditProductScreen(
                  initialProduct: product,
                ));
                fetchAllProducts();
              },
            );
          },
        ),
      ],
    );
  }
}

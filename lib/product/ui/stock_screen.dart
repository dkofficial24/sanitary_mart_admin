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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fetchAllProducts(); // Initial fetch
    });

    // Listener to detect when the user scrolls near the bottom and fetch more products
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 && // Trigger when 200px close to the bottom
          !context.read<ProductProvider>().isFetchingMore) {
        fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void fetchAllProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(isRefresh: true);
  }

  void fetchMoreProducts() {
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
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
            return Column(
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
                          context.read<ProductProvider>().updateSearchQuery('');
                          fetchAllProducts(); // Refresh the list after clearing search
                        },
                      ),
                    ),
                    onChanged: (query) {
                      context.read<ProductProvider>().updateSearchQuery(query);
                    },
                  ),
                ),
                Expanded(
                  child: body(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget body(ProductProvider provider) {
    if (provider.state == ProviderState.loading && provider.products.isEmpty) {
      return const ShimmerGridListWidget();
    } else if (provider.state == ProviderState.error && provider.products.isEmpty) {
      return ErrorRetryWidget(onRetry: fetchAllProducts);
    }

    if (provider.filteredProducts.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.filteredProducts.length + (provider.hasMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.filteredProducts.length) {
          final product = provider.filteredProducts[index];
          return ProductListViewItemWidget(
            product: product,
            onPressed: (context) async {
              await Get.to(AddEditProductScreen(initialProduct: product));
              fetchAllProducts(); // Refresh after editing a product
            },
          );
        } else {
          // Show loading indicator when fetching more products
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

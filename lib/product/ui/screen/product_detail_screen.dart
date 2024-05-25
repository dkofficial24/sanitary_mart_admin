import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Category? selectedCategory;
  Brand? selectedBrand;
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchBrandAndCategory(
        widget.product.categoryId,
        widget.product.brandId,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero widget for smooth product image transition from product list
            Hero(
              tag: widget.product.id!, // Use product ID as unique tag
              child: SizedBox(
                height: Get.width - 32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(widget.product.image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display product name with larger font size
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // Display discounted price if available
                  if (widget.product.discountAmount != null) ...[
                    Row(
                      children: [
                        Text(
                          // Display original price with strikethrough
                          '₹${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        if (widget.product.discountPercentage != null)
                          Text(
                            // Display discounted price with larger font
                            '₹${(widget.product.price * (1 - widget.product.discountPercentage! / 100)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        if (widget.product.discountAmount != null)
                          Text(
                            // Display discounted price with larger font
                            '₹${(widget.product.price - widget.product.discountAmount!).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      '₹${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10.0),
                  // Display brand and category if available
                  if (widget.product.brandName != null)
                    Row(
                      children: [
                        const Text('Brand: '),
                        Text(widget.product.brandName!),
                      ],
                    ),
                  if (widget.product.categoryName != null)
                    Row(
                      children: [
                        const Text('Category: '),
                        Text(widget.product.categoryName!),
                      ],
                    ),
                  const SizedBox(height: 10.0),
                  // Display available stock
                  Row(
                    children: [
                      const Text('Available Stock: '),
                      Text('${widget.product.stock}'),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Display product description
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future fetchBrandAndCategory(String categoryId, String brandId) async {
    isLoading = true;
    setState(() {

    });
    CategoryProvider categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    BrandProvider brandProvider =
        Provider.of<BrandProvider>(context, listen: false);

    final result = await Future.wait([
      categoryProvider.fetchCategoryById(categoryId),
      brandProvider.fetchBrandById(brandId)
    ]);

    selectedCategory = result.isNotEmpty ? result[0] as Category? : null;
    selectedBrand = result.length > 1 ? result[1] as Brand? : null;
    widget.product.categoryName =selectedCategory?.name;
    widget.product.brandName =selectedBrand?.name;
    if (mounted) {
      isLoading = false;
      setState(() {});
    }

    FirebaseAnalytics.instance.logEvent(name: 'fetch_brand_and_category');
  }
}

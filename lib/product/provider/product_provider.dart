import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/route_manager.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/service/brand_firebase_service.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/service/category_firebase_service.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';
import 'package:sanitary_mart_admin/product/service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService;
  final CategoryFirebaseService categoryFirebaseService;
  final BrandFirebaseService brandFirebaseService;

  ProductProvider({
    required this.productService,
    required this.categoryFirebaseService,
    required this.brandFirebaseService,
  });

   List<Product> products = [];
  List<Category> categories = [];
  List<Brand> brands = [];
  ProviderState state = ProviderState.idle;
  bool error = false;

  String _searchQuery = '';
  bool _isAscending = true;
  Timer? _debounce;

  bool hasMoreProducts = true;
  bool isFetchingMore = false;

  String get searchQuery => _searchQuery;

  bool get isAscending => _isAscending;

  List<Product> _filterProductList = [];

  List<Product> get filteredProducts =>_filterProductList;

  /// Updates the search query and fetches matching products
  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      searchProduct(_searchQuery);
    });
  }

  /// Toggles the sort order and fetches products again
  void toggleSortOrder() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  void clearProducts() {
    _filterProductList = [];
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      state = ProviderState.loading;
      notifyListeners();

      if (product.image != null) {
        File file = await AppUtil.compressImage(File(product.image!));
        String path = await productService.uploadImage(file.path);
        product.image = path;
      }
      String id = await productService.addProduct(product);
      product.id = id;
      await addCategoryBrandAssociation(product.categoryId, product.brandId);
      _filterProductList.add(product);
      AppUtil.showToast('Product added successfully!');
      state = ProviderState.idle;
      Get.back();
      FirebaseAnalytics.instance.logEvent(name: 'product_added');
    } catch (e) {
      state = ProviderState.error;
      error = true;
      FirebaseAnalytics.instance.logEvent(name: 'error_product_added');
      AppUtil.showToast('Unable to add product. Error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      state = ProviderState.loading;
      notifyListeners();

      if (product.image != null && product.image!.isNotEmpty) {
        if (!product.image!.startsWith('http://') &&
            !product.image!.startsWith('https://')) {
          File file = await AppUtil.compressImage(File(product.image!));
          String path = await productService.uploadImage(file.path);
          product.image = path;
        }
      }

      await productService.updateProduct(product);
      AppUtil.showToast('Product updated successfully!');
      Get.back();
      state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'update_product');
    } catch (e) {
      state = ProviderState.error;
      error = true;
      FirebaseAnalytics.instance.logEvent(name: 'error_update_product');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addCategoryBrandAssociation(
      String categoryId, String brandId) async {
    final CollectionReference association =
        FirebaseFirestore.instance.collection('category_brand');
    await association.add({
      'categoryId': categoryId,
      'brandId': brandId,
    });
    FirebaseAnalytics.instance.logEvent(name: 'add_category_brand_association');
  }

  Future<void> fetchCategoriesAndBrands() async {
    try {
      state = ProviderState.loading;
      notifyListeners();
      final items = await Future.wait([
        categoryFirebaseService.getCategories(),
        brandFirebaseService.getBrands()
      ]);
      categories = items[0] as List<Category>;
      brands = items[1] as List<Brand>;
      state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_category_and_brands');
    } catch (e) {
      state = ProviderState.error;
      error = true;
      AppUtil.showToast('Unable to fetch product $e');
      FirebaseAnalytics.instance
          .logEvent(name: 'error_fetch_category_and_brands');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategoryBrand(
      String categoryId, String brandId) async {
    try {
      state = ProviderState.loading;
      notifyListeners();
      _filterProductList = await productService.fetchProductsByCategoryBrand(
          categoryId, brandId);
      Product.sortByCreated(_filterProductList);
      state = ProviderState.idle;
      FirebaseAnalytics.instance
          .logEvent(name: 'fetch_products_by_category_brand');
    } catch (e) {
      state = ProviderState.error;
      error = true;
      AppUtil.showToast('Unable to fetch product $e');
      FirebaseAnalytics.instance
          .logEvent(name: 'error_fetch_products_by_category_brand');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      state = ProviderState.loading;
      notifyListeners();

      await productService.deleteProduct(id);
      _filterProductList.removeWhere((element) => element.id == id);
      state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'delete_product');
    } catch (e) {
      state = ProviderState.error;
      error = true;
      FirebaseAnalytics.instance.logEvent(name: 'error_delete_product');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchProducts({int limit = 10, bool isRefresh = false}) async {
    if (isFetchingMore || (!hasMoreProducts && !isRefresh))
      return; // Prevent duplicate fetch

    try {
      if (isRefresh) {
        state = ProviderState.loading;
        error = false;
        hasMoreProducts = true;
        productService.resetPagination(); // Reset pagination for initial load
        filteredProducts.clear(); // Clear the existing products
      }

      notifyListeners();

      // Fetch products from service (pagination handled there)
      final newProducts = await productService.fetchProducts(limit: limit);

      if (newProducts.isNotEmpty) {
        filteredProducts.addAll(newProducts);
        products.clear();
        products.addAll(newProducts);
      }

      if (newProducts.length < limit) {
        hasMoreProducts =
            false; // No more products available if batch is less than limit
      }
    } catch (e) {
      error = true;
    } finally {
      state = ProviderState.idle;
      isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchProduct(String query) async {
    try {
      _filterProductList = products;
      notifyListeners();
      if(query.isEmpty)return;
      error = false;
      state = ProviderState.loading;
      notifyListeners();
      _filterProductList = await productService.fetchProductsFromQuery(query);
      hasMoreProducts=false;
      state = ProviderState.idle;
      notifyListeners();
    } on SocketException {
      print('searchProduct1 error');
      error = true;
      state = ProviderState.error;
    } on TimeoutException {
      print('searchProduct2 error ');
      error = true;
    } catch (e) {
      print('searchProduct3 error $e');
      // error = true;
      // state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }
}

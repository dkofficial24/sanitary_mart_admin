import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
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

  bool isLoading = false;
  bool error = false;

  void clearProducts(){
    products = [];
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      isLoading = true;
      error = false;
      state = ProviderState.loading;
      notifyListeners();

      ///compress file size
      if (product.image != null) {
        File file = await AppUtil.compressImage(File(product.image!));
        String path = await productService.uploadImage(file.path);
        product.image = path;
      }
      String id = await productService.addProduct(product);
      product.id = id;
      await addCategoryBrandAssociation(product.categoryId, product.brandId);
      products.add(product);
      AppUtil.showToast('Product added successfully!');
      isLoading = false;
      state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'product_added');
    } catch (e) {
      state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_product_added');
      AppUtil.showToast('Unable to add product.Error: $e');
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

  Future fetchCategoriesAndBrands() async {
    try {
      isLoading = true;
      error = false;
      state = ProviderState.loading;
      notifyListeners();
      final items = await Future.wait([
        categoryFirebaseService.getCategories(),
        brandFirebaseService.getBrands()
      ]);
      categories = items[0] as List<Category>;
      brands = items[1] as List<Brand>;
      isLoading = false;
      state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_category_and_brands');
    } catch (e) {
      error = true;
      isLoading = false;
      state = ProviderState.error;
      AppUtil.showToast('Unable to fetch product $e');
      FirebaseAnalytics.instance
          .logEvent(name: 'error_fetch_category_and_brands');
    } finally {
      notifyListeners();
    }
  }

  Future fetchProductsByCategoryBrand(String categoryId, String brandId) async {
    try {
      isLoading = true;
      error = false;
      state = ProviderState.loading;
      products = [];
      notifyListeners();
      products = await productService.fetchProductsByCategoryBrand(
          categoryId, brandId);
      isLoading = false;
      state = ProviderState.idle;
      FirebaseAnalytics.instance
          .logEvent(name: 'fetch_products_by_category_brand');
    } catch (e) {
      error = true;
      isLoading = false;
      state = ProviderState.error;
      AppUtil.showToast('Unable to fetch product $e');
      FirebaseAnalytics.instance
          .logEvent(name: 'error_fetch_products_by_category_brand');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      isLoading = true;
      error = false;
      state = ProviderState.loading;
      notifyListeners();

      await productService.deleteProduct(id);

      products.removeWhere((element) => element.id == id);

      isLoading = false;
      state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'delete_product');
    } catch (e) {
      isLoading = false;
      error = true;
      state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_delete_product');
    } finally {
      notifyListeners();
    }
  }

  Future updateProduct(Product product) async {
    try {
      isLoading = true;
      error = false;
      state = ProviderState.loading;
      notifyListeners();
      await productService.updateProduct(product);
      isLoading = false;
      state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'update_product');
    } catch (e) {
      isLoading = false;
      error = true;
      state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_update_product');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      state = ProviderState.loading;
      error = false;
      products.clear();
      notifyListeners();
      products = await productService.fetchAllProducts();
      state = ProviderState.idle;
    } catch (e) {
      state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }
}

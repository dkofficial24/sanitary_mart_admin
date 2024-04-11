import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/brand/service/brand_firebase_service.dart';
import 'package:sanitary_mart_admin/core/app_util.dart';
import 'package:sanitary_mart_admin/core/provider_state.dart';

class BrandProvider extends ChangeNotifier {
  final BrandFirebaseService firebaseService;

  BrandProvider(this.firebaseService);

  List<Brand> _brandList = [];
  ProviderState _state = ProviderState.idle;
  String? _error;
  bool imageUploading = false;

  List<Brand> get brandList => _brandList;

  ProviderState get state => _state;

  String? get error => _error;

  Future<void> addBrand(Brand item) async {
    try {
      _error = null;
      notifyListeners();
      String? imgUploadPath = await uploadBrandImage(item.imagePath);
      item.imagePath = imgUploadPath;
      await firebaseService.addBrand(item);
      AppUtil.showToast('Brand added successfully!');
      _brandList.add(item);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'add_brand');
    } catch (e) {
      _error = 'Failed to add item: $e';
      AppUtil.showToast(_error!);
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_add_brand');
    } finally {
      notifyListeners();
    }
  }

  Future<String?> uploadBrandImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      notifyListeners();
      _error = null;
      imageUploading = true;
      notifyListeners();
      File file = await AppUtil.compressImage(File(imagePath));
      String imageUrl = await firebaseService.uploadBrandImage(file.path);
      imageUploading = false;
      _state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'upload_brand_image');
      return imageUrl;
    } catch (e) {
      imageUploading = false;
      _state = ProviderState.error;
      _error = 'Failed to add item: $e';
      AppUtil.showToast(_error!);
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'error_upload_brand_image');
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchBrands() async {
    try {
      _state = ProviderState.loading;
      notifyListeners();

      _brandList = await firebaseService.getBrands();
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_brands');
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_fetch_brands');
    } finally {
      notifyListeners();
    }
  }

  Future<Brand?> fetchBrandById(String brandId) async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      Brand? brand = await firebaseService.fetchBrandById(brandId);
      _state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'fetch_brand_by_id');
      return brand;
    } catch (e) {
      _error = 'Unable to fetch brand';
      FirebaseAnalytics.instance.logEvent(name: 'error_fetch_brand_by_id');
      return null;
    } finally {
      _state = ProviderState.idle;
      notifyListeners();
    }
  }

  Future<void> fetchBrandsByCategory(String categoryId) async {
    try {
      _error = null;
      _brandList = [];
      _state = ProviderState.loading;
      notifyListeners();

      _brandList = await firebaseService.getBrandsByCategory(categoryId);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_brands_by_category');
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_fetch_brands_by_category');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateBrand(Brand item) async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();

      await firebaseService.updateBrand(item);
      int index = _brandList.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _brandList[index] = item;
      }

      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'update_brand');
    } catch (e) {
      _error = 'Failed to update item: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_update_brand');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();

      await firebaseService.deleteBrand(id);

      _brandList.removeWhere((element) => element.id == id);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'delete_brand');
    } catch (e) {
      _error = 'Failed to delete item: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_delete_brand');
    } finally {
      notifyListeners();
    }
  }
}

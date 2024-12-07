import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/category/service/category_firebase_service.dart';
import 'package:sanitary_mart_admin/core/app_util.dart';
import 'package:sanitary_mart_admin/core/provider_state.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryFirebaseService firebaseService;

  CategoryProvider(this.firebaseService);

  List<Category> _categoryList = [];
  ProviderState _state = ProviderState.idle;
  String? _error;
  bool imageUploading = false;

  List<Category> get categoryList => _categoryList;

  ProviderState get state => _state;

  String? get error => _error;

  Future<void> addCategory(Category item) async {
    try {
      resetStates();
      notifyListeners();
      String? imgUploadPath = await uploadCategoryImage(item.imagePath);
      item.imagePath = imgUploadPath;
      await firebaseService.addCategory(item);
      AppUtil.showToast('Category added successfully!');
      _categoryList.add(item);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'add_category');
    } catch (e) {
      _error = 'Failed to add item: $e';
      AppUtil.showToast(_error!);
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_add_category');
    } finally {
      notifyListeners();
    }
  }

  Future<String?> uploadCategoryImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      resetStates();
      imageUploading = true;
      _error = null;
      notifyListeners();
      File file = await AppUtil.compressImage(File(imagePath));
      String imageUrl = await firebaseService.uploadCategoryImage(file.path);
      imageUploading = false;
      _state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'upload_category_image');
      return imageUrl;
    } catch (e) {
      imageUploading = false;
      _state = ProviderState.error;
      _error = 'Failed to add item: $e';
      AppUtil.showToast(_error!);
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'error_upload_category_image');
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      resetStates();
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      _categoryList = await firebaseService.getCategories();
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'fetch_categories');
    } catch (e) {
      _error = 'Failed to fetch items: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_fetch_categories');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category item) async {
    try {
      resetStates();
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();

      await firebaseService.updateCategory(item);
      int index = _categoryList.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _categoryList[index] = item;
      }
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'update_category');
    } catch (e) {
      _error = 'Failed to update item: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_update_category');
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      resetStates();
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();

      await firebaseService.deleteCategory(id);
      _categoryList.removeWhere((element) => element.id == id);
      _state = ProviderState.idle;
      FirebaseAnalytics.instance.logEvent(name: 'delete_category');
    } catch (e) {
      _error = 'Failed to delete item: $e';
      _state = ProviderState.error;
      FirebaseAnalytics.instance.logEvent(name: 'error_delete_category');
    } finally {
      notifyListeners();
    }
  }

  Future<Category?> fetchCategoryById(String categoryId) async {
    try {
      resetStates();
      _error = null;
      _state = ProviderState.loading;
      notifyListeners();
      Category? category = await firebaseService.fetchCategoryById(categoryId);
      _state = ProviderState.idle;
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(name: 'fetch_category_by_id');
      return category;
    } catch (e) {
      _error = 'Unable to fetch category';
      FirebaseAnalytics.instance.logEvent(name: 'error_fetch_category_by_id');
      return null;
    } finally {
      _state = ProviderState.idle;
      notifyListeners();
    }
  }

  void resetStates() {
    _error = null;
    _state = ProviderState.idle;
    imageUploading = false;
  }
}

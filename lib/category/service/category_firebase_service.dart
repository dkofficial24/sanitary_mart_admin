import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanitary_mart_admin/category/model/category_model.dart';
import 'package:sanitary_mart_admin/core/firebase_base_service.dart';

class CategoryFirebaseService extends BaseService {
  static const String collection = 'categories';

  CategoryFirebaseService() : super(collection);
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> addCategory(Category item) async {
    await addData(item.toFirebase());
  }

  Future<List<Category>> getCategories() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection(collectionName).get();
      return snapshot.docs.map((doc) => Category.fromFirebase(doc)).toList();
    } catch (e) {
      print("Error getting categories: $e");
      return [];
    }
  }

  Future<Category?> fetchCategoryById(String categoryId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(
            'categories') // Replace 'categories' with your actual collection name
        .doc(categoryId)
        .get();

    if (docSnapshot.exists) {
      return Category.fromFirebase(docSnapshot);
    } else {
      print("Category not found");
      return null;
    }
  }

  Future<String> uploadCategoryImage(String path) async {
    return await uploadImage(path);
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(category.id)
          .update(category.toFirebase());
      print("Category updated successfully");
      return true; // Return true on successful update
    } catch (e) {
      print("Error updating category: $e");
      return false; // Return false if there's an error during update
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(categoryId)
          .delete();
      print("Category deleted successfully");
      return true;
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }
}
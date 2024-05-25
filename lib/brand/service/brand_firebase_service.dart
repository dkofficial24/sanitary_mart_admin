import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/brand/model/brand_model.dart';
import 'package:sanitary_mart_admin/core/firebase_base_service.dart';

class BrandFirebaseService extends BaseService {
  BrandFirebaseService() : super('brands');

  Future<List<Brand>> getBrands() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      return snapshot.docs.map((doc) => Brand.fromFirebase(doc)).toList();
    } catch (e) {
      // Handle errors appropriately
      print("Error getting brands: $e");
      return [];
    }
  }

  Future<String> addBrand(Brand item) async {
    return await addData(item.toFirebase());
  }

  Future<List<Brand>> getBrandsByCategory(String categoryId) async {
    final CollectionReference association =
        FirebaseFirestore.instance.collection('category_brand');
    final snapshot =
        await association.where('categoryId', isEqualTo: categoryId).get();
    List<Brand> brands = [];
    List<String> brandIds = [];
    for (QueryDocumentSnapshot associationDoc in snapshot.docs) {
      String brandId = associationDoc['brandId'];

      if (!brandIds.contains(brandId)) {
        brandIds.add(brandId);
        DocumentSnapshot brandSnapshot = await FirebaseFirestore.instance
            .collection('brands')
            .doc(brandId)
            .get();
        if (brandSnapshot.exists) {
          brands.add(Brand.fromFirebase(brandSnapshot));
        }
      }
    }
    return brands;
  }

  Future<String> uploadBrandImage(String path) async {
    return await uploadImage(path);
  }

  Future<bool> updateBrand(Brand brand) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(brand.id)
          .update(brand.toFirebase());
      print("Brand updated successfully");
      return true; // Return true on successful update
    } catch (e) {
      print("Error updating Brand: $e");
      return false; // Return false if there's an error during update
    }
  }

  Future<bool> deleteBrand(String brandId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(brandId)
          .delete();
      print("Brand deleted successfully");
      return true;
    } catch (e) {
      print("Error deleting Brand: $e");
      return false;
    }
  }

  Future<Brand?> fetchBrandById(String brandId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(
        'brands')
        .doc(brandId)
        .get();

    if (docSnapshot.exists) {
      return Brand.fromFirebase(docSnapshot);
    } else {
      print("Brand not found");
      return null;
    }
  }
}

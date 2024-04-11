import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/core/firebase_base_service.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';

class ProductService extends BaseService {
  ProductService() : super('products');

  Future addProduct(Product product) async {
    await addData(product.toFirebase());
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  Future<List<Product>> fetchProductsByBrand(String brandId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('brandId', isEqualTo: brandId)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  Future<String> uploadProductImage(String path) async {
    return await uploadImage(path);
  }

  Future<List<Product>> fetchProductsByCategoryBrand(
      String categoryId, String brandId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('brandId', isEqualTo: brandId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  Future updateProduct(Product product) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(product.id)
        .update(product.toFirebase());
  }

  Future deleteProduct(
    String productId,
  ) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(productId)
        .delete();
  }
}

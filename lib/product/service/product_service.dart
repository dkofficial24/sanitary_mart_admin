import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/order_item.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';

class ProductService extends BaseService {
  ProductService() : super('products');

  DocumentSnapshot? _lastDocument;

  Future<String> addProduct(Product product) async {
    return await addData(product.toFirebase());
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

  Future<List<Product>> fetchProducts({
    int limit = 10,
    bool isInitialLoad = false,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .limit(limit);

    // For subsequent fetches, start after the last document
    if (_lastDocument != null && !isInitialLoad) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    // Update the last document for pagination
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    // Map the documents to Product objects
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

  Future<void> updateProductQuantity(
      List<OrderItem> orderItems, {required bool delivered}) async {
    final CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    // Start a batch operation
    WriteBatch batch = FirebaseFirestore.instance.batch();


    for (int i = 0; i < orderItems.length; i++) {
      final orderItem = orderItems[i];
      DocumentReference productRef =
          productsCollection.doc(orderItem.productId);
      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        Product product = Product.fromFirebase(productSnapshot);
        int currentStock = product.stock;
        if (delivered) {
          if (currentStock >= orderItem.quantity) {
            batch.update(
                productRef, {'stock': currentStock - orderItem.quantity});
          } else {
            // Handle insufficient stock
            Log.d('Insufficient stock for product ${orderItem.productId}');
          }
        } else {
          batch
              .update(productRef, {'stock': currentStock + orderItem.quantity});
          Log.d(
              'Product status changed from deliver to other hence adding back the qty in stock');
        }
      } else {
        // Handle product not found
        print('Product ${orderItem.productId} not found');
      }
    }

    await batch.commit();
  }

  Future<List<Product>> fetchProductsFromQuery(String query) async {
    try {
      String capitalizedQuery =
          query.substring(0, 1).toUpperCase() + query.substring(1);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: capitalizedQuery)
          .where('name', isLessThanOrEqualTo: capitalizedQuery + '\uf8ff') // Ensures coverage of all matching characters
          .get();

      return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
    } catch (e) {
      // Log or handle errors
      print('Error fetching products: $e');
      return [];
    }
  }


  Future deleteProduct(
    String productId,
  ) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(productId)
        .delete();
  }


  void resetPagination() {
    _lastDocument = null;
  }
}

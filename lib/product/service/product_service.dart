import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/order/model/order_item.dart';
import 'package:sanitary_mart_admin/product/model/product_model.dart';

class ProductService extends BaseService {
  ProductService() : super('products');

  DocumentSnapshot? _lastDocument;

  Future<String> addProduct(Product product) async {
    String productId =  await addData(product.toFirebase());
    await storeKeywords(productId, product.name);
    return productId;
  }

  Future<void> storeKeywords(String productId, String productName) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Generate keywords for the product name
      final keywords = generateKeywords(productName);

      // Store keywords in the 'product_keywords' collection
      await firestore.collection('product_keywords').doc(productId).set({
        'productId': productId,
        'keywords': keywords,
      });
      print("Keywords stored successfully.");
    } catch (e) {
      print("Error storing keywords: $e");
      throw 'Unable to store keywords';
    }
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
    return searchProductsByKeyword(query);

      // QuerySnapshot snapshot;
      // String capitalizedQuery =
      //     query.substring(0, 1).toUpperCase() + query.substring(1);
      // snapshot = await FirebaseFirestore.instance
      //     .collection('products')
      //     .where('name', isGreaterThanOrEqualTo: capitalizedQuery)
      //     .where('name', isLessThan: '${capitalizedQuery}z')
      //     .get();
      // return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  }

  // Future<List<Product>> fetchProductsFromQuery(String query) async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('products')
  //       .where('keywords', arrayContains: query.toLowerCase())
  //       .get();
  //
  //   return snapshot.docs.map((doc) => Product.fromFirebase(doc)).toList();
  // }


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

  /// Generates a list of keywords in lowercase for a given name.
  List<String> generateKeywords(String name) {
    final words = name.toLowerCase().split(' '); // Split the name into individual words
    final keywords = <String>{}; // Use a Set to avoid duplicate keywords

    // Iterate through each word
    for (final word in words) {
      for (int i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i)); // Add prefixes to the set
      }
    }

    return keywords.toList(); // Convert the set to a list and return
  }


  // /// Updates all existing products in Firestore to store keywords in a different collection.
  // Future<void> updateProductsWithKeywordsInNewCollection() async {
  //   final firestore = FirebaseFirestore.instance;
  //
  //   try {
  //     // Fetch all products from the 'products' collection
  //     final snapshot = await firestore.collection('products').get();
  //
  //     if (snapshot.docs.isEmpty) {
  //       print("No products found to update.");
  //       return;
  //     }
  //
  //     WriteBatch batch = firestore.batch(); // Use a batch for efficient writes
  //
  //     for (final doc in snapshot.docs) {
  //       final data = doc.data();
  //       final productName = data['name'] as String?;
  //
  //       if (productName != null) {
  //         // Generate keywords for the product name
  //         final keywords = generateKeywords(productName);
  //
  //         // Store the keywords in a separate collection (e.g., 'product_keywords')
  //         final productKeywordsRef = firestore.collection('product_keywords').doc(doc.id);
  //
  //         // Create a new document with the keywords
  //         batch.set(productKeywordsRef, {
  //           'productId': doc.id,
  //           'keywords': keywords,
  //         });
  //       }
  //     }
  //
  //     // Commit the batch update
  //     await batch.commit();
  //     print('DineshKumarTag keyword success');
  //     print("All products updated with keywords in 'product_keywords' collection.");
  //   } catch (e) {
  //     print('DineshKumarTag keyword error $e');
  //     print("Error updating products with keywords: $e");
  //   }
  // }


  /// Fetch products by keyword search
  Future<List<Product>> searchProductsByKeyword(String keyword) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Perform the query on the 'product_keywords' collection
      final snapshot = await firestore.collection('product_keywords')
          .where('keywords', arrayContains: keyword.toLowerCase()) // Use 'arrayContains' to match any keyword
          .get();

      // If no products found
      if (snapshot.docs.isEmpty) {
        print("No products found for keyword: $keyword");
        return [];
      }

      // Map the snapshot to Product objects (from 'products' collection)
      List<Product> products = [];
      for (final doc in snapshot.docs) {
        final productId = doc['productId'];

        // Fetch the product data from the 'products' collection
        final productSnapshot = await firestore.collection('products').doc(productId).get();

        if (productSnapshot.exists) {
          final product = Product.fromFirebase(productSnapshot);
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      print("Error searching products by keyword: $e");
      return [];
    }
  }


}

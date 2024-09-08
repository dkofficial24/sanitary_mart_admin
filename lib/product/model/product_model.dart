import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String name;
  double price;
  String? image;
  String description;
  double? discountPercentage;
  double? discountAmount;
  String categoryId;
  String brandId;
  int stock;
  String? categoryName;
  String? brandName;
  int? created;
  int? modified;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.brandId,
    this.image,
    required this.stock,
    this.categoryName,
    this.discountAmount,
    this.discountPercentage,
    this.brandName,
    this.created,
    this.modified,
  });

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image ?? '',
      'description': description,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'categoryId': categoryId,
      'brandId': brandId,
      'stock': stock,
      'created': created,
      'modified': modified,
    };
  }

  static Product fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'],
      price: data['price'],
      image: data['image'],
      description: data['description'],
      discountAmount: data['discountAmount'],
      discountPercentage: data['discountPercentage'],
      categoryId: data['categoryId'],
      brandId: data['brandId'],
      stock: data['stock'],
      brandName: data['brandName'],
      categoryName: data['categoryName'],
      created: data['created'],
      modified: data['modified'],
    );
  }

  static List<Product> sortByModified(List<Product> products) {
    products.sort((a, b) => (b.modified ?? 0).compareTo(a.modified ?? 0));
    return products;
  }

  static List<Product> sortByCreated(List<Product> products) {
    products.sort((a, b) => (b.created ?? 0).compareTo(a.created ?? 0));
    return products;
  }
}

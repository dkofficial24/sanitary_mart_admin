import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String name;
  double price;
  String image;
  String description;
  double? discountPercentage;
  double? discountAmount;
  String categoryId;
  String brandId;
  int stock;
  String? categoryName;
  String? brandName;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.brandId,
    required this.image,
    required this.stock,
    this.categoryName,
    this.discountAmount,
    this.brandName,
  });

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'discountAmount': discountAmount,
      'categoryId': categoryId,
      'brandId': brandId,
      'stock': stock,
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
      categoryId: data['categoryId'],
      brandId: data['brandId'],
      stock: data['stock'],
      brandName: data['brandName'],
      categoryName: data['categoryName'],
    );
  }
}

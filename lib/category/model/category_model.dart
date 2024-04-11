import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String? id;
  String name;
  String? imagePath;

  Category({
    this.id,
    required this.name,
    this.imagePath,
  });

  // Convert Category object to a Map that can be stored in Firestore
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  // Create Category object from a Firestore DocumentSnapshot
  static Category fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'],
      imagePath: data['imagePath'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Category extends Equatable {
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

  @override
  List<Object?> get props => [name, id];
}

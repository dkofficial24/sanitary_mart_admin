import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Brand extends Equatable{
  String? id;
  String name;
  String? imagePath;

  Brand({
    this.id,
    required this.name,
    this.imagePath,
  });

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  static Brand fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: data['name'],
      imagePath: data['imagePath'],
    );
  }

  @override
  List<Object?> get props => [name, id];
}

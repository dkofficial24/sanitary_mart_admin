import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

abstract class BaseService {
  // Replace 'your_collection_name' with the actual collection name
  final String collectionName;

  BaseService(this.collectionName);

  Future<String> addData(Map<String, dynamic> data) async {
    try {
      final collectionRef =  FirebaseFirestore.instance.collection(collectionName);
      final docRef = collectionRef.doc();
      data['id'] = docRef.id;
      await docRef.set(data);
      return data['id'];
    } catch (e) {
      print("Error adding data: $e");
      throw 'Unable to add data';
    }
  }

  Future<void> updateData(String documentId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .update(data);
    } catch (e) {
      // Handle errors appropriately
      print("Error updating data: $e");
    }
  }

  Future<void> deleteData(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .delete();
    } catch (e) {
      // Handle errors appropriately
      print("Error deleting data: $e");
    }
  }

  Future<String> uploadImage(String path) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    String imageName = basename(path);
    Reference ref = storage.ref().child('$collectionName/$imageName');
    UploadTask uploadTask = ref.putFile(File(path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }
}

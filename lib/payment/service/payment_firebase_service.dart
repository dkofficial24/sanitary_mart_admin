import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanitary_mart_admin/payment/model/account_info_model.dart';

class PaymentFirebaseService {
  final String collectionName = 'payment_details';

  Future<List<PaymentInfo>> fetchPaymentInfo() async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    return snapshot.docs.map((doc) => PaymentInfo.fromFirebase(doc)).toList();
    throw 'Payment info not available';
  }

  Future<void> updatePaymentInfo(PaymentInfo accountInfo) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(accountInfo.id)
        .update(accountInfo.toJson());
  }

  Future<String> uploadQRCode(String path) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('payment_qr_codes/${path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(File(path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> addPaymentInfo(PaymentInfo accountInfo) async {
    final paymentRef = FirebaseFirestore.instance.collection(collectionName);
    final id = paymentRef.doc().id;
    accountInfo.id = id;
    await paymentRef.doc(id).set(accountInfo.toJson());
  }

  Future<void> deletePaymentInfo(String id) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(id)
        .delete();
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sanitary_mart_admin/payment/model/account_info_model.dart';

class PaymentFirebaseService {
  final String collectionName = 'payment_info';

  Future<PaymentInfo?> fetchPaymentInfo() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc('payment_info_id')
        .get();
    if (documentSnapshot.exists) {
      return PaymentInfo.fromFirebase(documentSnapshot);
    }else{
      return null;
    }
    throw 'Payment info not available';
  }

  Future<void> updatePaymentInfo(PaymentInfo accountInfo) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc('payment_info_id')
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
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc('payment_info_id').set(accountInfo.toJson());
  }
}

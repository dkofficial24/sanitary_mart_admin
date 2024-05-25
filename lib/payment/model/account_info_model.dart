import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentInfo {
  String upiId;
  String accountHolderName;
  String qrCodeUrl;

  PaymentInfo({
    required this.upiId,
    required this.accountHolderName,
    required this.qrCodeUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'upiId': upiId,
      'accountName': accountHolderName,
      'qrCodeUrl': qrCodeUrl,
    };
  }

  static PaymentInfo fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      upiId: json['upiId'],
      accountHolderName: json['accountName'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }

  static PaymentInfo fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return PaymentInfo(
      upiId: json['upiId'],
      accountHolderName: json['accountName'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }
}

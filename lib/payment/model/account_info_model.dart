import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentInfo {
  String? id;
  String upiId;
  String accountHolderName;
  String qrCodeUrl;

  PaymentInfo({
    this.id,
    required this.upiId,
    required this.accountHolderName,
    required this.qrCodeUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'upiId': upiId,
      'accountName': accountHolderName,
      'qrCodeUrl': qrCodeUrl,
    };
  }

  static PaymentInfo fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'],
      upiId: json['upiId'],
      accountHolderName: json['accountName'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }

  static PaymentInfo fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return PaymentInfo(
      id: json['id'],
      upiId: json['upiId'],
      accountHolderName: json['accountName'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }
}

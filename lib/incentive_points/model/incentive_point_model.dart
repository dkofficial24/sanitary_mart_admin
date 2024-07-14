import 'package:cloud_firestore/cloud_firestore.dart';

enum RedeemStatus { none, processing, accepted, rejected }

enum PointType { earned, credited }

class IncentivePointInfo {
  String? id;
  double totalPoints;
  int? created;
  int? updated;
  RedeemStatus redeemStatus;
  PointType pointType;

  IncentivePointInfo({
    this.id,
    required this.totalPoints,
    this.created,
    this.updated,
    this.redeemStatus = RedeemStatus.none,
    this.pointType = PointType.earned,
  });

  // Convert IncentivePointInfo object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalPoints': totalPoints,
      'created': created,
      'updated': updated,
      'redeemStatus': redeemStatus.index,
      'pointType': pointType.index,
    };
  }

  // Create IncentivePointInfo object from JSON
  factory IncentivePointInfo.fromJson(Map<String, dynamic> json) {
    return IncentivePointInfo(
      id: json['id'],
      totalPoints: json['totalPoints'],
      created: json['created'],
      updated: json['updated'],
      redeemStatus: RedeemStatus.values[json['redeemStatus']],
      pointType: PointType.values[json['pointType']],
    );
  }

  // Create IncentivePointInfo object from Firestore document
  factory IncentivePointInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncentivePointInfo.fromJson(data);
  }

  // Convert IncentivePointInfo object to Firestore document
  Map<String, dynamic> toDocument() {
    return toJson();
  }


  static RedeemStatus parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return RedeemStatus.processing;
      case 'accepted':
        return RedeemStatus.accepted;
      case 'rejected':
        return RedeemStatus.rejected;
      case 'none':
        return RedeemStatus.none;
      default:
        return RedeemStatus.none;
    }
  }
}

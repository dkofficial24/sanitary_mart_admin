import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/incentive_points/model/incentive_point_model.dart';

class IncentivePointService {
  Future<List<IncentivePointInfo>> getIncentivePointsHistory(String uId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .collection('data')
        .orderBy('updated', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => IncentivePointInfo.fromDocument(doc))
        .toList();
  }

  Future<num> getTotalIncentivePoints(String uId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .get();
    if (snapshot.exists) {
      final map = snapshot.data();
      if (map != null && map.containsKey('points')) {
        return map['points'];
      }
    }
    return 0.0;
  }

  Future<void> incrementIncentivePoints(String uId, double points) async {
    final docRef = FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId);
    num totalPoints = await getTotalIncentivePoints(uId);
    totalPoints += points;
    await docRef.set({'points': totalPoints}, SetOptions(merge: true));
  }

  Future<void> decrementIncentivePoints(String uId, double points) async {
    final docRef = FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId);
    num totalPoints = await getTotalIncentivePoints(uId);
    totalPoints -= points;
    await docRef.set({'points': totalPoints}, SetOptions(merge: true));
  }

  Future<void> updateIncentiveRedeemStatus(
      String uId,
      RedeemStatus redeemStatus,
      String incentivePointId,
      ) async {
    await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .collection('data')
        .doc(incentivePointId)
        .update({'redeemStatus': redeemStatus.index});
  }
}

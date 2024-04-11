import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanitary_mart_admin/order/model/customer_model.dart';

class CustomerFirebaseService {
  Future<List<Customer>> fetchCustomers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.map((doc) => Customer.fromJson(doc.data())).toList();
    } catch (e) {
      // Handle errors here
      print('Error fetching customers: $e');
      return []; // Return empty list or throw an exception as needed
    }
  }

  Future setVerificationStatus(String uid, bool approved) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'verified': approved,
    });
  }
}

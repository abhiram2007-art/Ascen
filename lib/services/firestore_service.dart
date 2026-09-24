import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Stream<DocumentSnapshot> userProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}

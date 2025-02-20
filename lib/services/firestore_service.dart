import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Users').doc(userId).update(data);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}

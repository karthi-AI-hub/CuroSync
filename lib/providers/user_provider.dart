import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? get userData => _userData;

  // Fetch User Data
  Future<void> fetchUserData(String userId) async {
    _userData = await _firestoreService.getUserProfile(userId);
    notifyListeners();
  }

  // Update User Data
  Future<void> updateUserData(String userId, Map<String, dynamic> newData) async {
    await _firestoreService.updateUserProfile(userId, newData);
    _userData = newData;
    notifyListeners();
  }
}

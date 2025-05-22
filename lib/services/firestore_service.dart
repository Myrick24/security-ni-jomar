import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save user profile data
  Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required String address,
    String? profilePictureUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'age': age,
      'gender': gender,
      'address': address,
      'profilePicture': profilePictureUrl,
      'email': user.email,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('users').doc(user.uid).update({
      ...data,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}

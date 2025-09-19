import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user signed in');
    await _firestore.collection('profiles').doc(user.uid).set({
      'name': profile.name,
      'age': profile.age,
      'dob': profile.dob,
      'sex': profile.sex,
      'phone': profile.phone,
      'pincode': profile.pincode,
      'profilePicture': profile.profilePicture,
      'email': user.email,
    });
  }

  Future<UserProfile?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('profiles').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final profile = UserProfile.instance;
    profile.update(
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      dob: data['dob'] ?? '',
      sex: data['sex'] ?? '',
      phone: data['phone'] ?? '',
      pincode: data['pincode'] ?? '',
      profilePicture: data['profilePicture'],
    );
    return profile;
  }
}

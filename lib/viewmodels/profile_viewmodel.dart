import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/models/user.dart';
import 'package:hedieaty3/services/firebase_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthMethod _authMethod = AuthMethod();
  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  Future<void> loadUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        _userModel = UserModel.fromMap(userDoc.data()!);
        notifyListeners(); // Notify UI to update
      } catch (e) {
        print("Error loading user profile: $e");
      }
    }
  }

}

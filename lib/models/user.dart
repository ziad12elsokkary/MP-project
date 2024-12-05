import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePictureUrl;

  // Constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  // Convert Firestore document data to UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'], // May be null
    );
  }

  // Convert UserModel object to Firestore document data (Map)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}

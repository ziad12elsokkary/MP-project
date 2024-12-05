import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String name;
  final String profilePicture;
  final String phoneNumber;
  final int upcomingEventCount;

  Friend({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.phoneNumber,
    this.upcomingEventCount = 0, // Default to 0 if not provided
  });

  // Factory constructor to create a Friend object from Firestore data
  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      id: data['id'],
      name: data['name'],
      profilePicture: data['profilePicture'],
      phoneNumber: data['phoneNumber'],
      upcomingEventCount: data['upcomingEventCount'] ?? 0, // Handle null values
    );
  }

  // Method to convert Friend object to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'upcomingEventCount': upcomingEventCount,
    };
  }
}

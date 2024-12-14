import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String friendId; // ID of the friend
  final String friendName; // Name of the friend
  final String profilePictureUrl; // Profile picture URL (if needed)

  Friend({
    required this.friendId,
    required this.friendName,
    required this.profilePictureUrl,
  });

  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      friendId: data['friendid'],
      friendName: data['friendName'],
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userid': userId, // Add the user ID who added the friend
      'friendid': friendId,
      'friendName': friendName,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}

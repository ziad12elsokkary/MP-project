class Friend {
  final String friendId;
  final String friendName;
  final String profilePictureUrl;
  final String userId;
  final int eventCount; // New property for event count

  Friend({
    required this.friendId,
    required this.friendName,
    required this.profilePictureUrl,
    required this.userId,
    this.eventCount = 0, // Default value is 0
  });

  Map<String, dynamic> toMap(String currentUserId) {
    return {
      'friendid': friendId,
      'friendName': friendName,
      'profilePictureUrl': profilePictureUrl,
      'userid': currentUserId,
    };
  }
}

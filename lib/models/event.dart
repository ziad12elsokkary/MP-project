import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String eventName;
  final String giftName;
  final DateTime eventDate;
  String status; // New field for event status
  final String userId; // New field to refer to the user who added the event

  Event({
    required this.id,
    required this.eventName,
    required this.giftName,
    required this.eventDate,
    this.status = "Upcoming", // Default status
    required this.userId,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(data['eventDate']);
    } catch (e) {
      parsedDate = DateTime.now(); // Use current date if eventDate is null or invalid
    }

    return Event(
      id: data['id'],
      eventName: data['eventName'],
      giftName: data['giftName'],
      eventDate: parsedDate,
      status: determineStatus(parsedDate), // Assign status based on date
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'giftName': giftName,
      'eventDate': eventDate.toIso8601String(), // Convert DateTime to ISO 8601 String
      'status': status,
      'userId': userId, // Include the user ID for reference
    };
  }

  // Determine the event status based on its date
  static String determineStatus(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now).inDays;

    if (difference > 7) {
      return "Upcoming";
    } else if (difference >= 0 && difference <= 7) {
      return "Current";
    } else {
      return "Past";
    }
  }
}

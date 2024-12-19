import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String eventName;
  final DateTime eventDate;
  String status; // New field for event status

  Event({
    required this.id,
    required this.eventName,
    required this.eventDate,
    this.status = "Upcoming", // Default status
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
      eventDate: parsedDate,
      status: determineStatus(parsedDate), // Assign status based on date
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(), // Convert DateTime to ISO 8601 String
      'status': status,
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

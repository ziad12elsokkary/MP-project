import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String eventName;
  final String giftName;
  final DateTime eventDate;
  String status; // New field for event status

  Event({
    required this.id,
    required this.eventName,
    required this.giftName,
    required this.eventDate,
    this.status = "Upcoming", // Default status
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      eventName: data['eventName'],
      giftName: data['giftName'],
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      status: determineStatus((data['eventDate'] as Timestamp).toDate()), // Assign status based on date
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'giftName': giftName,
      'eventDate': eventDate,
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

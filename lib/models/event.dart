// lib/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String eventName;
  final String giftName;
  final DateTime eventDate;

  Event({
    required this.id,
    required this.eventName,
    required this.giftName,
    required this.eventDate,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      eventName: data['eventName'],
      giftName: data['giftName'],
      eventDate: (data['eventDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'giftName': giftName,
      'eventDate': eventDate,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hedieaty3/models/event.dart';

class EventListViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Event> events = [];

  Future<void> fetchEvents() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final snapshot = await _firestore
            .collection('events')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        events = snapshot.docs.map((doc) {
          return Event.fromMap(doc.data());
        }).toList();
      } catch (e) {
        print("Error fetching events: $e");
      }
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      events.removeWhere((event) => event.id == eventId);
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<void> updateEvent(String eventId, String eventName, String giftName,
      DateTime date) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'eventName': eventName,
        'giftName': giftName,
        'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      });
      final index = events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        events[index] = Event(id: eventId,
            eventName: eventName,
            giftName: giftName,
            eventDate: date);
      }
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  Future<Event> getEventById(String eventId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('events').doc(
          eventId).get();
      if (snapshot.exists) {
        return Event.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception("Event not found");
      }
    } catch (e) {
      throw Exception("Error fetching event: $e");
    }
  }

  Future<List<Event>> fetchEventsForFriend(String friendId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('friendId', isEqualTo: friendId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error fetching events for friend: $e');
      return [];
    }
  }

  Future<void> handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case "profile":
        Navigator.pushNamed(context, '/profile');
        break;
      case "pledged_gifts":
        Navigator.pushNamed(context, '/pledged-gifts');
        break;
      case "your_events":
        Navigator.pushNamed(context, '/event-list');
        break;
      case "your_gifts":
        Navigator.pushNamed(context, '/gift-list');
        break;
      default:
        break;
    }
  }
}

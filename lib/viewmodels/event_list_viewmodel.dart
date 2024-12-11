import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> updateEvent(String eventId, String eventName, String giftName, DateTime date) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'eventName': eventName,
        'giftName': giftName,
        'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      });
      final index = events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        events[index] = Event(id: eventId, eventName: eventName, giftName: giftName, eventDate: date);
      }
    } catch (e) {
      print("Error updating event: $e");
    }
  }
}




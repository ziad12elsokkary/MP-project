import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:hedieaty3/models/event.dart';

//
// class HomePageViewModel {
//   // Events list
//   final List<Map<String, String>> events = [
//     {'name': 'Birthday Party', 'date': 'Dec 20, 2024'},
//     {'name': 'Wedding', 'date': 'Jan 15, 2025'},
//   ];
//
//   // Delete an event
//   void deleteEvent(int index) {
//     events.removeAt(index);
//   }
//
//   // Handle menu selection
//   void handleMenuSelection(BuildContext context, String value) {
//     if (value == "profile") {
//       Navigator.pushNamed(context, '/profile'); // Navigate to Profile page
//     } else if (value == "pledged_gifts") {
//       Navigator.pushNamed(context, '/pledged-gifts'); // Navigate to Pledged Gifts page
//     }
//   }
// }

// lib/viewmodels/home_page_viewmodel.dart

class HomePageViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Event> events = []; // List to store events

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
      // After deletion, update the events list
      events.removeWhere((event) => event.id == eventId);
    } catch (e) {
      print("Error deleting event: $e");
    }
  }
}

void handleMenuSelection(BuildContext context, String value) {
  switch (value) {
    case "profile":
      Navigator.pushNamed(context, '/profile');
      break;
    case "pledged_gifts":
      Navigator.pushNamed(context, '/pledged-gifts');
      break;
    default:
      break;
  }
}

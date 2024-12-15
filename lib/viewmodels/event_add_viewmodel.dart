import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty3/models/event.dart';

class AddEventViewModel {
  DateTime? selectedDate;

  void pickDate(DateTime? date) {
    selectedDate = date;
  }

  Future<String> saveEvent(String eventName, String giftName, DateTime? date, {String? eventId}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        if (eventId == null) {
          // Adding a new event
          await FirebaseFirestore.instance.collection('events').add({
            'eventName': eventName,
            'giftName': giftName,
            'eventDate': Timestamp.fromDate(date!), // Ensure correct format
            'userId': currentUser.uid, // Add the userId to associate with the user
          });
        } else {
          // Updating an existing event
          await FirebaseFirestore.instance.collection('events').doc(eventId).update({
            'eventName': eventName,
            'giftName': giftName,
            'eventDate': Timestamp.fromDate(date!), // Ensure correct format
            'userId': currentUser.uid, // Ensure userId is not removed
          });
        }

        return eventId == null ? "Event added successfully!" : "Event updated successfully!";
      } catch (e) {
        return "Error saving event: $e";
      }
    }
    return "User not logged in.";
  }
}

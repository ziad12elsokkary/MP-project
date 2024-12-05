import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventViewModel {
  DateTime? selectedDate;

  void pickDate(DateTime? date) {
    selectedDate = date;
  }

  Future<String> saveEvent(String eventName, String giftName, DateTime? date) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('events')
            .add({
          'eventName': eventName,
          'giftName': giftName,
          'date': date, // Save DateTime object
        });
        return "Event saved successfully!";
      } catch (e) {
        return "Error saving event: $e";
      }
    }
    return "User not logged in.";
  }
}

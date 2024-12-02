import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController giftNameController = TextEditingController();
  DateTime? selectedDate;

  // Function to pick a date using DatePicker
  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to add event to Firestore and return to HomePage
  Future<void> addEvent() async {
    if (selectedDate != null && eventNameController.text.isNotEmpty && giftNameController.text.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Store the event data in Firestore under the user's UID
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)  // Use the current user's UID
              .collection('events')
              .add({
            'eventName': eventNameController.text,
            'giftName': giftNameController.text,
            'date': Timestamp.fromDate(selectedDate!),  // Store the date as a Timestamp
          });

          // Clear the fields after adding the event
          eventNameController.clear();
          giftNameController.clear();
          setState(() {
            selectedDate = null;
          });

          // Show a snackbar to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event added successfully")),
          );

          // Pop and return to HomePage with success flag
          Navigator.pop(context, true);
        } catch (e) {
          print("Error adding event: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding event: $e")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and select a date")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: giftNameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(selectedDate == null
                    ? "Select Event Date"
                    : "${selectedDate?.toLocal()}".split(' ')[0]),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => pickDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addEvent,
              child: const Text("Add Event"),
            ),
          ],
        ),
      ),
    );
  }
}

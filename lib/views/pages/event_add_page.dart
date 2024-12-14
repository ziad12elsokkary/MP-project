import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventPage extends StatefulWidget {
  final Map<String, dynamic>? event; // Pass existing event data for modification

  const AddEventPage({super.key, this.event});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController giftNameController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      eventNameController.text = widget.event!['eventName'];
      giftNameController.text = widget.event!['giftName'];
      selectedDate = (widget.event!['date'] as Timestamp).toDate();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> modifyEvent() async {
    if (selectedDate != null && eventNameController.text.isNotEmpty && giftNameController.text.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('events')
              .doc(widget.event!['id'])
              .update({
            'eventName': eventNameController.text,
            'giftName': giftNameController.text,
            'date': Timestamp.fromDate(selectedDate!),  // Update the date as a Timestamp
          });

          // Show a snackbar to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event updated successfully")),
          );

          // Pop and return to EventListPage
          Navigator.pop(context, true);
        } catch (e) {
          print("Error modifying event: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating event: $e")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and select a date")),
      );
    }
  }

  Future<void> addEvent() async {
    if (selectedDate != null && eventNameController.text.isNotEmpty && giftNameController.text.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
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
        title: widget.event == null ? const Text("Add Event") : const Text("Edit Event"),
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
              onPressed: widget.event == null ? addEvent : modifyEvent,
              child: Text(widget.event == null ? "Add Event" : "Update Event"),
            ),
          ],
        ),
      ),
    );
  }
}
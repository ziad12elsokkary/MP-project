import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';

class EventEditPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventEditPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _giftNameController = TextEditingController();
  DateTime _eventDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _eventNameController.text = widget.event['eventName'];
    _giftNameController.text = widget.event['giftName'];
    _eventDate = (widget.event['date'] as Timestamp).toDate(); // Correctly parse Timestamp to DateTime
  }

  void _saveChanges() {
    final updatedEvent = {
      'id': widget.event['id'],
      'eventName': _eventNameController.text,
      'giftName': _giftNameController.text,
      'date': Timestamp.fromDate(_eventDate), // Convert DateTime to Timestamp
    };

    EventListViewModel().updateEvent(
      widget.event['id'],
      _eventNameController.text,
      _giftNameController.text,
      _eventDate,
    ).then((_) {
      Navigator.pop(context, updatedEvent);
    }).catchError((e) {
      print("Error updating event: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: "Event Name"),
            ),
            TextField(
              controller: _giftNameController,
              decoration: const InputDecoration(labelText: "Gift Name"),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _eventDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _eventDate = date;
                  });
                }
              },
              child: Text("Select Date: ${_eventDate.toLocal()}".split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}

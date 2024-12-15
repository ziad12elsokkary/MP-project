import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';
import 'package:hedieaty3/models/event.dart';

class EventEditPage extends StatefulWidget {
  final String eventId;

  const EventEditPage({required this.eventId, Key? key}) : super(key: key);

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime _eventDate = DateTime.now();
  final EventListViewModel _viewModel = EventListViewModel();

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    // Fetch event details from Firestore based on eventId
    Event event = await _viewModel.getEventById(widget.eventId);
    setState(() {
      _eventName = event.eventName;
      _eventDate = event.eventDate;
    });
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update the event in Firestore
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId) // The ID of the event to update
            .update({
          'eventName': _eventName,
          'eventDate': Timestamp.fromDate(_eventDate), // Update the existing eventDate field
        });

        // Return true to refresh events
        Navigator.pop(context, true);
      } catch (e) {
        print("Error updating event: $e");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Event"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _eventName,
                decoration: InputDecoration(labelText: "Event Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an event name";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _eventName = value;
                  });
                },
              ),
              Row(
                children: [
                  Text("Date: ${_eventDate.toLocal()}"),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _eventDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _eventDate) {
                        setState(() {
                          _eventDate = pickedDate;
                        });
                      }
                    },
                    child: Text("Pick Date"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEvent,
                child: Text("Update Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

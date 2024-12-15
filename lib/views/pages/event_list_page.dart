import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty3/models/event.dart';
import 'package:hedieaty3/views/pages/event_add_page.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';
import 'package:hedieaty3/views/pages/event_edit.dart';
import 'package:hedieaty3/services/firebase_service.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchUserEvents();
  }

  Future<void> fetchUserEvents() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userEvents = await FirebaseFirestore.instance
            .collection('events') // Access the top-level `events` collection
            .where('userId', isEqualTo: currentUser.uid) // Filter by userId
            .get();

        setState(() {
          events = userEvents.docs.map((doc) {
            DateTime date = (doc['eventDate'] as Timestamp).toDate(); // Ensure the key matches the updated structure
            String status = Event.determineStatus(date);

            return {
              'id': doc.id,
              'eventName': doc['eventName'],
              'date': date.toString(),
              'status': status,
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }


  Future<void> deleteEvent(String eventId, int index) async {
    try {
      // Delete the event directly from the top-level `events` collection
      await FirebaseFirestore.instance
          .collection('events') // Updated to target the new collection
          .doc(eventId) // Use the event's document ID
          .delete();

      // Remove the event from the local list
      setState(() {
        events.removeAt(index);
      });
    } catch (e) {
      print("Error deleting event: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Events"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              handleMenuSelection(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "profile",
                child: Text("Profile"),
              ),
              const PopupMenuItem(
                value: "pledged_gifts",
                child: Text("Pledged Gifts"),
              ),
              const PopupMenuItem(
                value: "your_events",
                child: Text("Your Events"),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Events",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: events.isEmpty
                  ? const Center(
                child: Text(
                  "No events yet. Add some!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(event['eventName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${event['date']}"),
                          Text("Status: ${event['status']}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteEvent(event['id'], index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventEditPage(eventId: event['id']), // Pass the Firestore document ID
                                ),
                              ).then((updatedEvent) {
                                if (updatedEvent != null) {
                                  fetchUserEvents(); // Refresh the events list after an update
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool eventAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventPage()),
          );

          if (eventAdded) {
            fetchUserEvents(); // Refresh the events list after adding an event
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void handleMenuSelection(BuildContext context, String value) {
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
      default:
        break;
    }
  }
}

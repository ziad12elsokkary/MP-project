import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty3/views/pages/event_add_page.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';
import 'package:hedieaty3/views/pages/event_edit.dart';

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

  // Fetch events for the logged-in user from Firestore
  Future<void> fetchUserEvents() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userEvents = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('events')
            .get();

        setState(() {
          events = userEvents.docs.map((doc) {
            DateTime date = (doc['date'] as Timestamp).toDate();
            String status;
            if (date.isAfter(DateTime.now().add(Duration(days: 7)))) {
              status = 'Upcoming';
            } else if (date.isAfter(DateTime.now())) {
              status = 'Current';
            } else {
              status = 'Past';
            }

            return {
              'id': doc.id,
              'eventName': doc['eventName'],
              'giftName': doc['giftName'],
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

  // Handle delete event
  Future<void> deleteEvent(String eventId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('events')
          .doc(eventId)
          .delete();

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
                          Text("Gift: ${event['giftName']}"),
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
                              // Navigate to the event edit page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventEditPage(event: event),
                                ),
                              ).then((updatedEvent) {
                                if (updatedEvent != null) {
                                  fetchUserEvents();  // Refresh the events list
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
            fetchUserEvents();  // Refresh the events list after adding an event
          }
        },
        child: const Icon(Icons.add),
      ),
    );
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
    case "your_events":
      Navigator.pushNamed(context, '/event-list');
      break;
    default:
      break;
  }
}

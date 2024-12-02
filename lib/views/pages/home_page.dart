import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty3/views/pages/event_list_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            return {
              'id': doc.id,
              'eventName': doc['eventName'],
              'giftName': doc['giftName'],
              'date': (doc['date'] as Timestamp).toDate().toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  // Handle menu item selection for profile and pledged gifts
  void handleMenuSelection(BuildContext context, String value) {
    if (value == "profile") {
      Navigator.pushNamed(context, '/profile');
    } else if (value == "pledged_gifts") {
      Navigator.pushNamed(context, '/pledged-gifts');
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
                      subtitle: Text(event['date']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Delete event from Firestore using event ID
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('events')
                              .doc(event['id'])  // Use event ID
                              .delete()
                              .then((_) {
                            setState(() {
                              events.removeAt(index);
                            });
                          });
                        },
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
          // When returning from AddEventPage, the page will be refreshed
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

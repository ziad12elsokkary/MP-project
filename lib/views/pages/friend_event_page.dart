import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/models/event.dart';
import 'package:hedieaty3/views/pages/friend_gift.dart'; // Import the gift list page

class FriendEventsPage extends StatelessWidget {
  final String friendId;
  final String friendName;

  FriendEventsPage({required this.friendId, required this.friendName});

  Future<List<Event>> fetchFriendEvents() async {
    final firestore = FirebaseFirestore.instance;
    final eventsSnapshot = await firestore
        .collection('events')
        .where('userId', isEqualTo: friendId) // Filter events where userId matches the friendId
        .get();

    return eventsSnapshot.docs.map((doc) {
      final data = doc.data();
      DateTime parsedDate;
      try {
        parsedDate = (data['eventDate'] as Timestamp).toDate(); // Ensure date is parsed correctly
      } catch (e) {
        parsedDate = DateTime.now(); // Use current date if eventDate is null or invalid
      }

      return Event(
        id: doc.id,
        eventName: data['eventName'],
        eventDate: parsedDate,
        status: Event.determineStatus(parsedDate), // Determine event status
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$friendName's Events"),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchFriendEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to EventGiftListPage when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventGiftListPage(eventId: event.id, eventName: event.eventName),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Event Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(event.eventName),
                            SizedBox(height: 4.0),
                            Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(event.eventDate.toLocal().toString().split(' ')[0]), // Display date in a readable format
                            SizedBox(height: 4.0),
                            Text("Status:", style: TextStyle(fontWeight: FontWeight.bold, color: getStatusColor(event.status))),
                            Text(event.status, style: TextStyle(color: getStatusColor(event.status))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.green;
      case 'Current':
        return Colors.orange;
      case 'Past':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

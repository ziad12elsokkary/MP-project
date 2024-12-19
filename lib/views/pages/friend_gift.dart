import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventGiftListPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventGiftListPage({Key? key, required this.eventId, required this.eventName}) : super(key: key);

  Future<void> updateGiftStatus(String giftId, bool isPledged, String giftName) async {
    final firestore = FirebaseFirestore.instance;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Get the eventId from the gift
      final giftDoc = await firestore.collection('gifts').doc(giftId).get();
      if (!giftDoc.exists) throw Exception("Gift not found");

      final eventId = giftDoc['eventId'];

      // Get the userId (event owner) from the event
      final eventDoc = await firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) throw Exception("Event not found");

      final friendId = eventDoc['userId'];

      // Update the gift's status
      await firestore.collection('gifts').doc(giftId).update({
        'status': isPledged ? 'pledged' : 'available',
        'pledgedBy': isPledged ? currentUserId : null,
      });

      // Add a notification for the friend (event owner)
      if (isPledged) {
        final notificationMessage = 'Your friend has pledged "$giftName"!';
        await firestore.collection('notifications').add({
          'recipientId': friendId,
          'message': notificationMessage,
          'timestamp': FieldValue.serverTimestamp(),
          'giftId': giftId,
          'giftName': giftName,
          'pledgedBy': currentUserId,
          'seen': false, // Default to not seen
        });
      }
    } catch (e) {
      print("Error updating gift status or sending notification: $e");
    }
  }

  Future<List<Gift>> fetchGiftsForEvent() async {
    final firestore = FirebaseFirestore.instance;
    final giftsSnapshot = await firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    return giftsSnapshot.docs.map((doc) {
      return Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> _markNotificationAsSeen(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'seen': true});
    } catch (e) {
      print("Error marking notification as seen: $e");
    }
  }

  void _listenForNotifications(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('seen', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          final notificationId = doc.id;
          final notificationMessage = doc['message'];

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Notification"),
                content: Text(notificationMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      _markNotificationAsSeen(notificationId);
                      Navigator.pop(context);
                    },
                    child: Text("Dismiss"),
                  ),
                ],
              );
            },
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gifts for $eventName"),
      ),
      body: FutureBuilder<List<Gift>>(
        future: fetchGiftsForEvent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No gifts found for this event.'));
          } else {
            final gifts = snapshot.data!;
            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];

                // Determine if the checkbox should be visible
                final isCheckboxVisible =
                    (gift.status == 'available') || (gift.status == 'pledged' && gift.pledgedBy == FirebaseAuth.instance.currentUser!.uid);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(gift.name),
                          SizedBox(height: 4.0),
                          Text("Price:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("\$${gift.price.toStringAsFixed(2)}"),
                          SizedBox(height: 4.0),
                          Text("Status:", style: TextStyle(fontWeight: FontWeight.bold, color: getStatusColor(gift.status))),
                          Text(gift.status, style: TextStyle(color: getStatusColor(gift.status))),
                          SizedBox(height: 4.0),

                          // Conditionally display the CheckboxListTile
                          if (isCheckboxVisible)
                            CheckboxListTile(
                              value: gift.status == 'pledged',
                              onChanged: (bool? value) {
                                if (value != null) {
                                  updateGiftStatus(gift.id, value, gift.name);
                                }
                              },
                              title: Text('Pledged'),
                            ),
                        ],
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
      case 'available':
        return Colors.green;
      case 'pledged':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

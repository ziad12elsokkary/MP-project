import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/gift.dart';
import 'package:hedieaty3/views/pages/pledged_gifts_page.dart'; // Adjust import path as necessary

class EventGiftListPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventGiftListPage({Key? key, required this.eventId, required this.eventName}) : super(key: key);

  Future<void> updateGiftStatus(String giftId, bool isPledged) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('gifts').doc(giftId).update({
      'status': isPledged ? 'pledged' : 'available',
    });

    if (isPledged) {
      // Save pledged gift details to a "pledged_gifts" collection
      await firestore.collection('pledged_gifts').add({
        'giftId': giftId,
        'eventId': eventId,
        'timestamp': Timestamp.now(),
      });
    } else {
      // Remove from "pledged_gifts" collection if marked as available
      final pledgedGifts = await firestore.collection('pledged_gifts').where('giftId', isEqualTo: giftId).get();
      for (var doc in pledgedGifts.docs) {
        await firestore.collection('pledged_gifts').doc(doc.id).delete();
      }
    }
  }

  Future<List<Gift>> fetchGiftsForEvent() async {
    final firestore = FirebaseFirestore.instance;
    final giftsSnapshot = await firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId) // Filter gifts by eventId
        .get();

    return giftsSnapshot.docs.map((doc) {
      return Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPledgedGifts() async {
    final firestore = FirebaseFirestore.instance;
    final pledgedSnapshot = await firestore.collection('pledged_gifts').where('eventId', isEqualTo: eventId).get();

    List<Map<String, dynamic>> pledgedGifts = [];
    for (var doc in pledgedSnapshot.docs) {
      final giftDoc = await firestore.collection('gifts').doc(doc['giftId']).get();
      final friendDoc = await firestore.collection('users').doc(giftDoc['userId']).get(); // Adjust as needed
      final eventDoc = await firestore.collection('events').doc(eventId).get();

      pledgedGifts.add({
        'giftName': giftDoc['name'],
        'friendName': friendDoc['name'], // Adjust as needed
        'eventDate': eventDoc['date'].toDate(), // Adjust as needed
      });
    }

    return pledgedGifts;
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
                          CheckboxListTile(
                            value: gift.status == 'pledged',
                            onChanged: (bool? value) {
                              if (value != null) {
                                updateGiftStatus(gift.id, value);
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

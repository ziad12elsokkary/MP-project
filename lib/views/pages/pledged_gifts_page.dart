// pledged_gifts_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PledgedGiftsPage extends StatelessWidget {
  final String eventId;

  const PledgedGiftsPage({Key? key, required this.eventId}) : super(key: key);

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
        title: Text("Pledged Gifts"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found.'));
          } else {
            final pledgedGifts = snapshot.data!;
            return ListView.builder(
              itemCount: pledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = pledgedGifts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gift Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(gift['giftName']),
                          SizedBox(height: 4.0),
                          Text("Friend:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(gift['friendName']),
                          SizedBox(height: 4.0),
                          Text("Event Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${gift['eventDate']}"),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  // Fetch pledged gifts with event and user details
  Future<void> _fetchPledgedGiftsWithDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Query gifts pledged by the current user
        final giftsQuery = await FirebaseFirestore.instance
            .collection('gifts')
            .where('pledgedBy', isEqualTo: currentUser.uid)
            .get();

        final List<Map<String, dynamic>> giftsWithDetails = [];

        for (var giftDoc in giftsQuery.docs) {
          final giftData = giftDoc.data();
          final eventId = giftData['eventId'];

          // Fetch event details
          final eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();

          if (eventDoc.exists) {
            final eventData = eventDoc.data();
            final userId = eventData?['userId'];
            final eventDate = (eventData?['eventDate'] as Timestamp?)?.toDate();

            // Fetch user details
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data();
              final userName = userData?['name'];

              // Combine gift, event, and user details
              giftsWithDetails.add({
                'giftName': giftData['name'] ?? 'Unnamed Gift',
                'eventDate': eventDate,
                'userName': userName ?? 'Unknown User',
              });
            }
          }
        }

        setState(() {
          pledgedGifts = giftsWithDetails;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching gifts with details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPledgedGiftsWithDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
          ? const Center(child: Text('No pledged gifts found.'))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return GestureDetector(
            onTap: () {
              // Handle gift tap (e.g., navigate to gift details page)
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
                      Text("Gift Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(gift['giftName']),
                      SizedBox(height: 4.0),
                      Text("Event Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(gift['eventDate']?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'),
                      SizedBox(height: 4.0),
                      Text("Event Owner:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(gift['userName']),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

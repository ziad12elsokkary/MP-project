import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PledgedGiftsPage extends StatelessWidget {
  // Extracts the user ID from the route arguments
  String? _getUserId(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as String?;
  }

  // Fetch pledged gifts for the specific user
  Future<List<Map<String, dynamic>>> _fetchPledgedGifts(String userId) async {
    try {
      final giftsCollection = FirebaseFirestore.instance.collection('gifts');
      final querySnapshot = await giftsCollection
          .where('status', isEqualTo: 'pledged')
          .where('pledgedBy', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Return an empty list if no gifts are found
      }

      return querySnapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _getUserId(context);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pledged Gifts'),
        ),
        body: Center(child: Text('No user ID found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gifts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPledgedGifts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading gifts. Please try again later.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found.'));
          }

          final gifts = snapshot.data!;

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return ListTile(
                title: Text(gift['name'] ?? 'Gift Name'),
                subtitle: Text(gift['description'] ?? 'No description available'),
                trailing: Text(gift['status'] ?? ''),
                onTap: () {
                  // Navigate to gift details or perform another action
                  print('Selected Gift ID: ${gift['id']}');
                },
              );
            },
          );
        },
      ),
    );
  }
}

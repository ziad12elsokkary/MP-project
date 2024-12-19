import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/gift.dart';
import 'package:hedieaty3/views/pages/gift_add.dart';
import 'package:hedieaty3/views/pages/gift_edit.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;

  const GiftListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];

  @override
  void initState() {
    super.initState();
    fetchGifts();
  }

  Future<void> fetchGifts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('eventId', isEqualTo: widget.eventId)
          .get();

      setState(() {
        gifts = snapshot.docs.map((doc) {
          return Gift.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print("Error fetching gifts: $e");
    }
  }

  Future<void> deleteGift(String giftId) async {
    try {
      await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();
      setState(() {
        gifts.removeWhere((gift) => gift.id == giftId);
      });
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift List"),
        centerTitle: true,
      ),
      body: gifts.isEmpty
          ? const Center(child: Text("No gifts yet. Add some!"))
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(gift.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: ${gift.category}"),
                  Text("Price: \$${gift.price.toStringAsFixed(2)}"),
                  Text("Status: ${gift.status}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteGift(gift.id!);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GiftEditPage(giftId: gift.id),
                        ),
                      );

                      if (updated == true) {
                        fetchGifts(); // Refresh the list after editing
                      }
                    },
                  ),

                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool giftAdded = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftAddPage(eventId: widget.eventId),
            ),
          );

          if (giftAdded) {
            fetchGifts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

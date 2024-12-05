import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/friend.dart';

class HomePageViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Friend>> fetchFriends() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('friends').get();
      return snapshot.docs.map((doc) {
        // Add the document ID as part of the Friend object
        final data = doc.data() as Map<String, dynamic>;
        return Friend.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  Future<void> addFriend(String phoneNumber, String name, String profilePicture) async {
    try {
      await _firestore.collection('friends').add({
        'phoneNumber': phoneNumber,
        'name': name,
        'profilePicture': profilePicture,
        'upcomingEventCount': 0, // Default value
      });
      print('Friend added to Firestore');
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  void addFriendDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final profilePictureController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: "Enter phone number"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Enter name"),
              ),
              TextField(
                controller: profilePictureController,
                decoration: const InputDecoration(hintText: "Enter profile picture URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final phoneNumber = phoneController.text;
                final name = nameController.text;
                final profilePicture = profilePictureController.text;

                if (phoneNumber.isNotEmpty && name.isNotEmpty && profilePicture.isNotEmpty) {
                  addFriend(phoneNumber, name, profilePicture);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Friend'),
            ),
          ],
        );
      },
    );
  }

  void handleMenuSelection(BuildContext context, String value) {
    // Handle menu selection logic here
    print("Selected menu option: $value");
  }

  void viewGiftList(BuildContext context, Friend friend) {
    // Navigate to the gift list page for the selected friend
    print("View gift list of ${friend.name}");
  }
}


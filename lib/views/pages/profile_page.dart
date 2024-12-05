import 'package:flutter/material.dart';
import 'package:hedieaty3/models/user.dart';  // Import the UserModel class
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty3/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;
  TextEditingController _urlController = TextEditingController(); // Controller for URL input

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load user data from Firestore
  void _loadProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _userModel = UserModel.fromMap(userDoc.data()!);  // Convert Firestore data to UserModel
      });
    }
  }

  void _showImageURLDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Image URL'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(hintText: 'Enter the image URL'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String url = _urlController.text;
                if (url.isNotEmpty) {
                  // Update profile picture URL in Firestore using the new method
                  String res = await AuthMethod().updateProfilePictureUrl(
                    _auth.currentUser!.uid, // User ID
                    url,                     // The URL provided by the user
                  );

                  showSnackBar(context, res);  // Show success or error message

                  // Reload profile after updating
                  if (res == "Profile picture updated successfully") {
                    _loadProfile();  // Reload profile data
                  }
                  Navigator.of(context).pop();
                } else {
                  showSnackBar(context, 'Please enter a valid URL');
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Allows scrolling if the keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _userModel == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,  // Ensure the column does not take up more space than needed
            children: [
              // This Align widget will make sure the content is centered horizontally
              Align(
                alignment: Alignment.topCenter,  // Top and center of the screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,  // Center all child widgets horizontally
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _userModel!.profilePictureUrl != null && _userModel!.profilePictureUrl!.isNotEmpty
                          ? NetworkImage(_userModel!.profilePictureUrl!)
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    const SizedBox(height: 16),

                    // User's Name
                    Text(
                      _userModel!.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // User's Email
                    Text(
                      _userModel!.email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Change Profile Picture Button
                    ElevatedButton(
                      onPressed: _showImageURLDialog,
                      child: const Text("Change Profile Picture"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

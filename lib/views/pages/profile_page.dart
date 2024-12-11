import 'package:flutter/material.dart';
import 'package:hedieaty3/models/user.dart';
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthMethod _authMethod = AuthMethod(); // Use the AuthMethod from firebase_service
  UserModel? _userModel;

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
        _userModel = UserModel.fromMap(userDoc.data()!); // Convert Firestore data to UserModel
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: _userModel == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _userModel!.profilePictureUrl != null &&
                    _userModel!.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(_userModel!.profilePictureUrl!)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                _userModel!.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _userModel!.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Call the signOut function from firebase_service
                  _authMethod.signOut(
                        () {
                      Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
                    },
                        (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

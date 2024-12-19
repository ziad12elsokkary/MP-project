import 'package:flutter/material.dart';
import 'package:hedieaty3/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/services/helper.dart'; // Import the local database helper

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;

  const EditProfilePage({Key? key, required this.userModel}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController profilePictureUrlController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userModel.name);
    phoneController = TextEditingController(text: widget.userModel.phone ?? '');
    profilePictureUrlController = TextEditingController(
        text: widget.userModel.profilePictureUrl ?? '');
  }

  Future<void> _updateProfile() async {
    try {
      // Firestore Update
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userModel.uid)
          .update({
        'name': nameController.text,
        'phone': phoneController.text,
        'profilePictureUrl': profilePictureUrlController.text,
      });

      // Local Database Update
      final updatedUser = {
        'uid': widget.userModel.uid,
        'name': nameController.text,
        'email': widget.userModel.email, // Keep email unchanged
        'phone': phoneController.text,
        'profilePictureUrl': profilePictureUrlController.text,
      };

      await LocalDatabaseHelper().updateUser(widget.userModel.uid, updatedUser);

      Navigator.pop(context, true); // Success - Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: profilePictureUrlController,
                decoration:
                const InputDecoration(labelText: "Profile Picture URL"),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

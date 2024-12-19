import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // SignUp User with phone number and profile picture
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
    required String phone,  // Add phone parameter
    required File? profilePic,  // Add profile picture parameter
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty && phone.isNotEmpty) {
        // Register user in Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Upload profile picture to Firebase Storage (if provided)
        String profilePictureUrl = '';
        if (profilePic != null) {
          // Create a reference to the storage location for the profile picture
          Reference storageRef = _storage.ref().child('profile_pictures/${cred.user!.uid}');

          // Upload the image to Firebase Storage
          UploadTask uploadTask = storageRef.putFile(profilePic);
          TaskSnapshot taskSnapshot = await uploadTask;

          // Get the download URL of the uploaded image
          profilePictureUrl = await taskSnapshot.ref.getDownloadURL();
        }

        // Add user details (including phone number and profile picture URL) to Firestore
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
          'phone': phone,  // Store phone number
          'profilePictureUrl': profilePictureUrl,  // Store profile picture URL
        });

        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = "Email is already registered. Please log in.";
      } else {
        res = e.message ?? "An unknown error occurred";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // LogIn User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = "No user found for this email. Please sign up.";
      } else if (e.code == 'wrong-password') {
        res = "Incorrect password. Please try again.";
      } else {
        res = e.message ?? "An unknown error occurred";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  //
  // Future<void> signOut({Function? onSignOutSuccess, Function? onSignOutError}) async {
  //   try {
  //     await _auth.signOut();
  //     if (onSignOutSuccess != null) {
  //       onSignOutSuccess(); // Trigger success callback
  //     }
  //   } catch (e) {
  //     if (onSignOutError != null) {
  //       onSignOutError(e); // Trigger error callback
  //     } else {
  //       print("Error during sign out: $e");
  //     }
  //   }
  // }
  // Sign-out function
  Future<void> signOut(Function onSuccess, Function(String) onError) async {
    try {
      await _auth.signOut();
      onSuccess(); // Call the onSuccess callback
    } catch (e) {
      onError("Error during sign out: $e"); // Call the onError callback
    }
  }

  // Update User Profile Picture
  Future<String> updateProfilePicture(String userId, File profilePic) async {
    String res = "Some error occurred";
    try {
      // Create a reference to the storage location for the new profile picture
      Reference storageRef = _storage.ref().child('profile_pictures/$userId');

      // Upload the new image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(profilePic);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String profilePictureUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile picture URL in Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePictureUrl': profilePictureUrl,
      });

      res = "Profile picture updated successfully";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
  Future<String> updateProfilePictureUrl(String userId, String profilePictureUrl) async {
    String res = "Some error occurred";
    try {
      // Check if URL is valid before updating
      final Uri? uri = Uri.tryParse(profilePictureUrl);
      if (uri != null && uri.hasAbsolutePath) {
        // Update the user's profile picture URL in Firestore
        await _firestore.collection('users').doc(userId).update({
          'profilePictureUrl': profilePictureUrl,  // Update with new URL
        });

        res = "Profile picture updated successfully";
      } else {
        res = "Invalid URL";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }



}

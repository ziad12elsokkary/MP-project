import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Add user details to Firestore
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
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


  // SignOut
  signOut() async {
    await _auth.signOut();
  }
}

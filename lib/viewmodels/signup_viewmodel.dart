import 'package:flutter/material.dart';
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:hedieaty3/services/local_database_service.dart';
import 'package:hedieaty3/utils/constants.dart';
import 'package:hedieaty3/views/pages/home_page.dart';

class SignupViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void signupUser(BuildContext context) async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty) {
      showSnackBar(context, "All fields are required");
      return;
    }

    _setLoading(true);

    String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      phone: phoneController.text,
      profilePic: null,
    );

    if (res == "success") {
      Map<String, dynamic> userData = {
        'ID': emailController.text,
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'imageurl': null,
      };

      try {
        await _databaseService.insertUser(userData);
      } catch (e) {
        showSnackBar(context, "Failed to save user locally: $e");
        _setLoading(false);
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      showSnackBar(context, res);
    }

    _setLoading(false);
  }
}

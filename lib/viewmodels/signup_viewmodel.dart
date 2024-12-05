import 'package:flutter/material.dart';
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:hedieaty3/utils/constants.dart';
import 'package:hedieaty3/views/pages/home_page.dart';

class SignupViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // Phone controller
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Sign up method
  void signupUser(BuildContext context) async {
    _setLoading(true);

    String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      phone: phoneController.text,
      profilePic: null, // Include phone number during signup
    );

    _setLoading(false);

    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>  HomePage(),
        ),
      );
    } else {
      showSnackBar(context, res); // Show error message
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose(); // Dispose phone controller as well
    super.dispose();
  }
}

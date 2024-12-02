import 'package:flutter/material.dart';
import 'package:hedieaty3/services/firebase_service.dart';
import 'package:hedieaty3/utils/constants.dart';

class LoginViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthMethod _authMethod = AuthMethod();

  Future<String> loginUser(BuildContext context) async {
    String res = await _authMethod.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res != "success") {
      showSnackBar(context, res);
    }

    return res;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

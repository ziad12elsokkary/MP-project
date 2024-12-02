import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // Delay for 5 seconds before navigating to LoginPage
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name
            const Text(
              'Hedieaty',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.cyan, // Update to match your branding
              ),
            ),
            const SizedBox(height: 20),
            // App Logo
            Image.asset(
              'asset/gift.png', // Update path if needed
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            // Circular Progress Indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

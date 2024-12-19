import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty3/views/pages/home_page.dart';
import 'package:hedieaty3/views/pages/login_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty3/main.dart'; // Update with your actual app import

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Login successfully with real Firebase database', (WidgetTester tester) async {
    // Initialize the app
    await tester.pumpWidget(const MyApp()); // Replace with your actual app widget

    // Wait for the splash screen to settle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigate to the LoginScreen
    final loginLink = find.text("Don't have an account?");
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    // Verify LoginScreen is displayed
    expect(find.byType(LoginPage), findsOneWidget);

    // Enter email
    final emailField = find.byType(TextField).at(0); // Assuming the email field is the first TextField
    await tester.enterText(emailField, 'ziad3@gmail.com');
    await tester.pump();

    // Enter password
    final passwordField = find.byType(TextField).at(1); // Assuming the password field is the second TextField
    await tester.enterText(passwordField, 'ziad31234');
    await tester.pump();

    // Tap the login button
    final loginButton = find.text("Log In");
    await tester.tap(loginButton);
    await tester.pump();

    // Simulate delay for login process
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify successful login by checking for a unique element on the HomePage
    expect(find.byType(HomePage), findsOneWidget); // Adjust this based on HomePage content
  });
}

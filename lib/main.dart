import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/views/pages/event_list_page.dart';
import 'package:hedieaty3/views/pages/home_page.dart';
import 'package:hedieaty3/views/pages/loading_page.dart';
import 'package:hedieaty3/views/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty3/views/pages/profile_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Starting point is LoadingPage
      routes: {
        '/': (context) => const LoadingPage(), // LoadingPage first
        '/login': (context) => const LoginPage(),
          '/profile': (context) => const ProfilePage(),
          '/add-event': (context) => const AddEventPage(), // Future implementatio
// After LoadingPage, navigate to LoginPage
      },
    );
  }
}
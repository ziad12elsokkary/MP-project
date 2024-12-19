import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty3/models/user.dart';
import 'package:hedieaty3/views/pages/event_add_page.dart';
import 'package:hedieaty3/views/pages/event_list_page.dart';
import 'package:hedieaty3/views/pages/gift_list_page.dart';
import 'package:hedieaty3/views/pages/home_page.dart';
import 'package:hedieaty3/views/pages/loading_page.dart';
import 'package:hedieaty3/views/pages/login_page.dart';
import 'package:hedieaty3/views/pages/pledged_gifts_page.dart';
import 'package:hedieaty3/views/pages/profile_page.dart';
import 'package:hedieaty3/views/pages/edit_profile.dart'; // Import EditProfilePage
import 'package:hedieaty3/models/gift.dart';

void main() async {
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
        '/editProfile': (context) => EditProfilePage(
          userModel: ModalRoute.of(context)!.settings.arguments as UserModel,
        ), // New route for editing profile
        '/add-event': (context) => const AddEventPage(),
        '/event-list': (context) => const EventListPage(),
        '/pledged-gifts': (context) => PledgedGiftsPage(),
        // '/gift-list':(context)=> GiftListPage(userId: '',),// Future implementation
      },
    );
  }
}

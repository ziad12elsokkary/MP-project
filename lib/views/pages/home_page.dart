import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty3/models/event.dart';
import 'package:hedieaty3/models/friend.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';
import 'package:hedieaty3/views/pages/friend_event_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Friend> _friendsList = [];
  List<Friend> _filteredFriends = [];
  final EventListViewModel eventModel = EventListViewModel();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  // Load friends from Firestore
  Future<void> _loadFriends() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      // Step 1: Fetch the list of friend IDs from the 'friends' collection
      final friendsSnapshot = await _firestore
          .collection('friends')
          .where('userid', isEqualTo: userId)
          .get();

      final friendIds = friendsSnapshot.docs
          .map((doc) => doc['friendid'] as String)
          .toList();

      if (friendIds.isEmpty) {
        setState(() {
          _friendsList = [];
          _filteredFriends = [];
        });
        return;
      }

      // Step 2: Fetch detailed friend data from the 'users' collection
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      final friendsData = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          friendId: doc.id, // Document ID is the friend ID
          friendName: data['name'],
          profilePictureUrl: data['profilePictureUrl'] ?? '',
          userId: userId, // The user who added this friend
        );
      }).toList();

      // Update the state with the fetched friend data
      setState(() {
        _friendsList = friendsData;
        _filteredFriends = _friendsList;
      });
    } catch (e) {
      print("Error loading friends: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading friends.")),
      );
    }
  }

  // Filter friends based on search query
  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _friendsList;
      } else {
        _filteredFriends = _friendsList.where((friend) {
          return friend.friendName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Add friend dialog
  Future<void> _addFriendDialog() async {
    final TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "Enter phone number"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final phone = phoneController.text.trim();
                if (phone.isNotEmpty) {
                  await _addFriend(phone);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Add friend by phone number
  Future<void> _addFriend(String phone) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
      // Look up the user by their phone number
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this phone number.")),
        );
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final friendId = userDoc.id; // Use userDoc.id as the friend ID

      if (friendId == userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You cannot add yourself as a friend.")),
        );
        return;
      }

      // Check if the friend is already in the 'friends' collection
      final existingFriendQuery = await _firestore
          .collection('friends')
          .where('userid', isEqualTo: userId)
          .where('friendid', isEqualTo: friendId)
          .limit(1)
          .get();

      if (existingFriendQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This friend is already added.")),
        );
        return;
      }

      // Add the friend relationship to the 'friends' collection
      final friendName = userDoc['name'];
      final profilePictureUrl = userDoc['profilePictureUrl'];
      final newFriend = Friend(friendId: friendId, friendName: friendName, profilePictureUrl: profilePictureUrl, userId: userId);

      await _firestore.collection('friends').add(newFriend.toMap(userId));

      setState(() {
        _friendsList.add(newFriend);
        _filteredFriends = _friendsList;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${friendName} added as a friend!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding friend: $e")),
      );
    }
  }






  // Count upcoming events for a friend
  Future<int> _countUpcomingEvents(String friendId) async {
    try {
      // Query the events collection in Firestore
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events') // Access the events collection
          .where('userId', isEqualTo: friendId) // Filter by friend ID
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now())) // Filter upcoming events
          .get();

      return eventsSnapshot.size; // Return the count of matching events
    } catch (e) {
      print("Error counting upcoming events: $e");
      return 0; // Return 0 in case of an error
    }
  }



  // Navigate to the friend's events page
  void _onFriendTapped(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendEventsPage(
          friendId: friend.friendId,
          friendName: friend.friendName, // Ensure you pass the friend's name here
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              eventModel.handleMenuSelection(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "profile",
                child: Text("Profile"),
              ),
              const PopupMenuItem(
                value: "pledged_gifts",
                child: Text("Pledged Gifts"),
              ),
              const PopupMenuItem(
                value: "your_events",
                child: Text("Your Events"),
              ),

            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFriends,
              decoration: const InputDecoration(
                labelText: "Search friends",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredFriends.isEmpty
                ? const Center(child: Text("No friends found."))
                : ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                return FutureBuilder<int>(
                  future: _countUpcomingEvents(friend.friendId), // Use the userId for counting events
                  builder: (context, snapshot) {
                    String eventCountText;
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        int eventCount = snapshot.data!;
                        eventCountText = eventCount > 0
                            ? "$eventCount upcoming events"
                            : "No upcoming events";
                      } else {
                        eventCountText = "Loading...";
                      }
                    } else {
                      eventCountText = "Loading...";
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: friend.profilePictureUrl.isNotEmpty
                            ? NetworkImage(friend.profilePictureUrl)
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                      title: Text(friend.friendName),
                      subtitle: Text(eventCountText),
                      onTap: () => _onFriendTapped(friend),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addFriendDialog,
            child: const Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }
}
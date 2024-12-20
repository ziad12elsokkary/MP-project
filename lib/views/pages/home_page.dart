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
  bool showNotificationPopup = false;
  String notificationMessage = '';
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _listenForNotifications(); // Listen for notifications
  }

  Future<void> _loadFriends() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      // Load the list of friends for the current user
      final friendsSnapshot = await _firestore
          .collection('friends')
          .where('userid', isEqualTo: userId)
          .get();

      if (friendsSnapshot.docs.isEmpty) {
        setState(() {
          _friendsList = [];
          _filteredFriends = [];
        });
        return;
      }

      final friendIds = friendsSnapshot.docs
          .map((doc) => doc['friendid'] as String)
          .toList();

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      final friendsData = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          friendId: doc.id,
          friendName: data['name'],
          profilePictureUrl: data['profilePictureUrl'] ?? '',
          userId: userId,
        );
      }).toList();

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

  void _filterFriends(String query) {
    setState(() {
      _filteredFriends = query.isEmpty
          ? _friendsList
          : _friendsList.where((friend) {
        return friend.friendName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _addFriendDialog() async {
    final TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            key: Key('addnumber'),
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

  Future<void> _addFriend(String phone) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
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
      final friendId = userDoc.id;

      if (friendId == userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You cannot add yourself as a friend.")),
        );
        return;
      }

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

  Future<int> _countUpcomingEvents(String friendId) async {
    try {
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: friendId)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .get();

      return eventsSnapshot.size;
    } catch (e) {
      print("Error counting upcoming events: $e");
      return 0;
    }
  }

  void _listenForNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('pledgedBy', isNotEqualTo: userId) // Exclude notifications where pledgedBy matches userId
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['seen'] == true) continue; // Skip already seen notifications

        setState(() {
          notificationMessage = doc['message'];
        });

        // Show the popup if no existing entry
        if (_overlayEntry == null) {
          _overlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notificationMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () async {
                          // Update Firestore to mark the notification as seen
                          await _firestore.collection('notifications').doc(doc.id).update({'seen': true});

                          // Remove the overlay entry
                          _overlayEntry?.remove();
                          _overlayEntry = null; // Clear the reference
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          Overlay.of(context)?.insert(_overlayEntry!);
        }
      }
    });
  }


  void _onFriendTapped(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendEventsPage(
          friendId: friend.friendId,
          friendName: friend.friendName,
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
                  future: _countUpcomingEvents(friend.friendId),
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
                            : const AssetImage('assets/default_profile.png'),
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
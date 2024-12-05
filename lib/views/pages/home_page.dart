import 'package:flutter/material.dart';
import 'package:hedieaty3/viewmodels/home_viewmodel.dart';
import 'package:hedieaty3/models/friend.dart';
import 'package:hedieaty3/viewmodels/event_list_viewmodel.dart';

class HomePage extends StatelessWidget {

  final HomePageViewModel viewModel = HomePageViewModel();
  final EventListviewModel eventModel = EventListviewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
             handleMenuSelection(context, value);
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
          // Search functionality (optional, can be added if needed)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                // Implement search functionality if needed
              },
            ),
          ),
          // Friend List Display
          Expanded(
            child: FutureBuilder<List<Friend>>(
              future: viewModel.fetchFriends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading friends'));
                }

                final friends = snapshot.data ?? [];
                if (friends.isEmpty) {
                  return Center(child: Text('No friends found.'));
                }

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.profilePicture),
                      ),
                      title: Text(friend.name),
                      subtitle: Text(friend.upcomingEventCount > 0
                          ? "Upcoming Events: ${friend.upcomingEventCount}"
                          : "No events available"),
                      onTap: () => viewModel.viewGiftList(context, friend),
                    );
                  },
                );
              },
            ),
          ),
          // Button to add new friends
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => viewModel.addFriendDialog(context),
              icon: Icon(Icons.add),
              label: Text("Add Friend"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

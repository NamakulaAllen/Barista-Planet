import 'package:flutter/material.dart';
import 'community_home.dart'; // Import the CommunityHome screen

class CommunityScreen extends StatelessWidget {
  final List<Map<String, dynamic>>
      groups; // List of groups passed to this screen

  const CommunityScreen({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(groups[index]["name"]), // Display group name
              onTap: () {
                // Navigate to CommunityHome when a group is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CommunityHome(), // Navigate to CommunityHome
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

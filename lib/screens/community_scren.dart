import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'group_chat_screen.dart'; // For navigating to the group chat

class CommunityScreen extends StatelessWidget {
  final String userId;

  CommunityScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var groups = snapshot.data!.docs;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
              return ListTile(
                title: Text(group['name']),
                onTap: () {
                  // Navigate to the group chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(
                        groupId: group.id,
                        groupName: group['name'],
                        userId: userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

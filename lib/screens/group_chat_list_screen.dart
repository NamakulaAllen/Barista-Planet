import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_chat_screen.dart';
import 'create_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  final String currentUserId;

  const GroupListScreen(
      {super.key, required this.currentUserId, required String userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No groups found."));
          } else {
            final groups = snapshot.data!.docs;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isAdmin = group['adminId'] == currentUserId;
                return ListTile(
                  title: Text(group['name']),
                  subtitle: isAdmin ? const Text("You are the admin") : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          groupId: group.id,
                          currentUserId: currentUserId,
                          isAdmin: isAdmin,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateGroupScreen(currentUserId: currentUserId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

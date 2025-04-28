import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'one_on_one_chat_screen.dart';

class OneOnOneChatList extends StatelessWidget {
  final String userId;

  const OneOnOneChatList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final chats = snapshot.data!.docs;
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final participants = List<String>.from(chat['participants']);
            if (!participants.contains(userId)) return Container();
            return ListTile(
              title: Text(
                  "Chat with ${participants.firstWhere((id) => id != userId)}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OneOnOneChatScreen(
                      currentUserId: userId,
                      otherUserId:
                          participants.firstWhere((id) => id != userId),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

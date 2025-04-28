import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  final bool isAdmin;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.isAdmin,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  void _deleteMessage(String messageId, bool forEveryone) {
    if (forEveryone) {
      _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } else {
      _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deletedFor': FieldValue.arrayUnion([widget.currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Chat"),
        actions: widget.isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    // Add functionality to accept join requests
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Accept join requests")),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages"));
                } else {
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isDeletedForMe = (message['deletedFor'] as List?)
                              ?.contains(widget.currentUserId) ??
                          false;

                      if (isDeletedForMe) {
                        return const ListTile(title: Text("[Message deleted]"));
                      }

                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['senderId']),
                        trailing: widget.isAdmin ||
                                message['senderId'] == widget.currentUserId
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteMessage(message.id, widget.isAdmin);
                                },
                              )
                            : null,
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

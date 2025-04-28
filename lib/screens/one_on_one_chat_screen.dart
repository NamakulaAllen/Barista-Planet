import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OneOnOneChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const OneOnOneChatScreen(
      {super.key, required this.currentUserId, required this.otherUserId});

  @override
  State<OneOnOneChatScreen> createState() => _OneOnOneChatScreenState();
}

class _OneOnOneChatScreenState extends State<OneOnOneChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  void sendMessage() {
    String chatId = generateChatId(widget.currentUserId, widget.otherUserId);
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'text': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    String chatId = generateChatId(widget.currentUserId, widget.otherUserId);

    return Scaffold(
      appBar: AppBar(title: Text("Chat with User")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No chat"));
                } else {
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['senderId']),
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
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

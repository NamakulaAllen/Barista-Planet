import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupChat extends StatefulWidget {
  final String groupId;
  const GroupChat({super.key, required this.groupId});

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late IO.Socket socket;
  List messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io("http://localhost:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();
    socket.emit("join", {"group_id": widget.groupId});

    socket.on("message", (data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  void sendMessage() {
    String text = messageController.text;
    socket.emit("send_message", {
      "group_id": widget.groupId,
      "sender": "User Name",
      "text": text,
    });
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Group Chat")),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(
                    "${messages[index]["sender"]}: ${messages[index]["text"]}"));
          },
        )),
        TextField(controller: messageController),
        IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
      ]),
    );
  }
}

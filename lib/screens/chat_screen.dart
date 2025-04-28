import 'package:flutter/material.dart';
import 'one_on_one_list_screen.dart';
import 'group_chat_list_screen.dart';
import 'announcement_screen.dart';

class ChatScreen extends StatelessWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chat Community"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "One-on-One"),
              Tab(text: "Groups"),
              Tab(text: "Announcements"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OneOnOneChatList(userId: userId),
            GroupListScreen(
              userId: userId,
              currentUserId: '',
            ),
            AnnouncementScreen(),
          ],
        ),
      ),
    );
  }
}

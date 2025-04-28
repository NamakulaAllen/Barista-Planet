import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'one_on_one_chat_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ??
        "unknown"; // Get current user ID

    return Scaffold(
      appBar: AppBar(title: const Text("Members")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No members found."));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OneOnOneChatScreen(
                          currentUserId:
                              currentUserId, // Use the actual current user ID
                          otherUserId: user['id'],
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
    );
  }
}

// Fetch users from Firestore
Future<List<Map<String, dynamic>>> fetchUsers() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();
  return querySnapshot.docs
      .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
      .toList();
}

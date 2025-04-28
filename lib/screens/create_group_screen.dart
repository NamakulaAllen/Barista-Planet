import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CreateGroupScreen extends StatefulWidget {
  final String currentUserId;

  const CreateGroupScreen({super.key, required this.currentUserId});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group name cannot be empty")),
      );
      return;
    }

    // Generate a unique group ID
    final groupId = const Uuid().v4();

    // Create the group in Firestore
    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'name': groupName,
      'adminId': widget.currentUserId, // The creator becomes the admin
      'members': [widget.currentUserId], // Add the creator as the first member
      'requests': [], // Empty list for join requests
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Group created successfully!")),
    );

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: "Group Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createGroup,
              child: const Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}

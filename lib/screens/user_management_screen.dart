import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Color(0xFF794022),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show search functionality
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF794022)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          // Filter users based on search query
          List<DocumentSnapshot> filteredDocs = snapshot.data!.docs;
          if (_searchQuery.isNotEmpty) {
            filteredDocs = filteredDocs.where((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String name = data['name']?.toString().toLowerCase() ?? '';
              String email = data['email']?.toString().toLowerCase() ?? '';
              return name.contains(_searchQuery.toLowerCase()) ||
                  email.contains(_searchQuery.toLowerCase());
            }).toList();
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> userData =
                  filteredDocs[index].data() as Map<String, dynamic>;
              return _userTile(filteredDocs[index].id, userData);
            },
          );
        },
      ),
    );
  }

  // Search dialog for filtering users
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Users'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter name or email',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  // User tile widget
  Widget _userTile(String userId, Map<String, dynamic> userData) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.brown[200],
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(userData['name'] ?? 'Unknown'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userData['email'] ?? 'No email'),
          SizedBox(height: 4),
          Text(
            'Role: ${userData['role'] ?? 'User'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editUser(userId, userData);
          } else if (value == 'delete') {
            _confirmDeleteUser(userId);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit user dialog
  void _editUser(String userId, Map<String, dynamic> userData) {
    final TextEditingController nameController =
        TextEditingController(text: userData['name']);
    final TextEditingController emailController =
        TextEditingController(text: userData['email']);
    String? role = userData['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(labelText: 'Role'),
              items: ['Admin', 'Manager', 'Editor', 'User']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  role = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(userId).update({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': role,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User updated successfully')),
                );
                Navigator.pop(context); // Close the dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update user: $e')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Confirm delete user dialog
  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(userId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User deleted successfully')),
                );
                Navigator.pop(context); // Close the dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete user: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

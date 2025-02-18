import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'community_screen.dart'; // Import CommunityScreen

class CommunityHome extends StatefulWidget {
  const CommunityHome({super.key});

  @override
  _CommunityHomeState createState() => _CommunityHomeState();
}

class _CommunityHomeState extends State<CommunityHome> {
  List groups = [];
  String userId = "1"; // Replace with logged-in user's ID

  Future<void> fetchGroups() async {
    var response = await http.get(
      Uri.parse("http://localhost:5000/groups/$userId"),
      headers: {"Authorization": "Bearer YOUR_JWT_TOKEN"},
    );

    if (response.statusCode == 200) {
      setState(() {
        groups = json.decode(response.body);
      });

      // Navigate to the CommunityScreen after fetching the groups
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const CommunityScreen(
      //       groups: [],
      //     ),
      //   ),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Home")),
      body: Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator until groups are fetched
      ),
    );
  }
}

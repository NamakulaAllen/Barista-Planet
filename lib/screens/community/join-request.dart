import 'package:flutter/material.dart';

class JoinRequestScreen extends StatelessWidget {
  const JoinRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    List<Map<String, String>> availableGroups = [
      {"name": "Coffee Experts", "id": "3"},
      {"name": "Latte Art", "id": "4"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Request to Join")),
      body: ListView.builder(
        itemCount: availableGroups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(availableGroups[index]["name"]!),
            trailing: ElevatedButton(
              onPressed: () {
                // Send join request logic here
              },
              child: Text("Request"),
            ),
          );
        },
      ),
    );
  }
}

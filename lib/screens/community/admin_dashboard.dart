import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for join/group requests
    List<Map<String, String>> requests = [
      {"user": "Alice", "group": "Coffee Experts", "type": "join"},
      {"user": "Bob", "group": "New Espresso Club", "type": "create"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                "${requests[index]["user"]} requested to ${requests[index]["type"]} ${requests[index]["group"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Approve request logic
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Reject request logic
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RecentsScreen extends StatelessWidget {
  final List<String> history; // List to hold the names of recent pages

  const RecentsScreen(
      {super.key, required this.history, required List recentPages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF794022),
        title: const Text(
          'Recent Pages',
          style: TextStyle(color: Colors.white), // Set title text to white
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Set back arrow to white
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No recent pages visited yet.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(history[index]),
                  leading: const Icon(Icons.history),
                  onTap: () {
                    // Handle navigation for the selected recent page
                    // You can add logic here to navigate back to the specific page
                    // For now, it just shows a toast or alert when a page is tapped
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Visited: ${history[index]}')),
                    );
                  },
                );
              },
            ),
    );
  }
}

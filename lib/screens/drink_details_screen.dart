import 'package:flutter/material.dart';

class DrinkDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> drink;

  const DrinkDetailsScreen({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drink['name'] ?? 'Drink Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF794022), // Brown app bar background
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White arrow icon
          onPressed: () {
            Navigator.pop(context); // Navigate back when the arrow is tapped
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tap image to view in full screen
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pop(context), // Close when tapped
                        child: InteractiveViewer(
                          panEnabled: true, // Allow zooming & panning
                          child: Image.asset(
                            drink['image'] ?? 'assets/images/default.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  drink['image'] ?? 'assets/images/default.jpg',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: InteractiveViewer(
                            panEnabled: true,
                            child: Image.asset(
                              drink['image'] ?? 'assets/images/default.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "See Full Image",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredients:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black), // Black text for Ingredients
              ),
              ...?drink['ingredients']?.entries.map(
                    (entry) => Text('${entry.key}: ${entry.value}',
                        style: TextStyle(color: Colors.black)),
                  ),
              SizedBox(height: 10),
              Text(
                'Preparation:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black), // Black text for Preparation
              ),
              Text(drink['preparation'] ?? 'No preparation details available.',
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

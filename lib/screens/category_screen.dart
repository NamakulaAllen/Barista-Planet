import 'package:flutter/material.dart';
import 'drink_details_screen.dart'; // Import DrinkDetailsScreen

class CategoryScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> drinks;

  const CategoryScreen(
      {super.key, required this.category, required this.drinks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        backgroundColor: Color(0xFF794022), // Using brown for the app bar
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White arrow icon
          onPressed: () {
            Navigator.pop(context); // Navigate back on icon press
          },
        ),
      ),
      body: ListView.builder(
        itemCount: drinks.length,
        itemBuilder: (context, drinkIndex) {
          var drink = drinks[drinkIndex];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrinkDetailsScreen(
                      drink: drink,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        drink['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF794022), // Brown text for drink name
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF794022)
                            .withOpacity(0.6), // Brown arrow icon
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

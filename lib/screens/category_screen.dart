import 'package:flutter/material.dart';
import 'drink_details_screen.dart';

class CategoryDrinksScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> drinks;

  const CategoryDrinksScreen({
    super.key,
    required this.category,
    required this.drinks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: drinks.isEmpty
          ? const Center(child: Text("No drinks found in this category"))
          : ListView.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                final drink = drinks[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF794022).withOpacity(0.1),
                        child: const Icon(
                          Icons.local_drink,
                          color: Color(0xFF794022),
                        ),
                      ),
                      title: Text(drink['name'] ?? 'Unknown Drink'),
                      subtitle: Text(drink['preparation'] ?? ''),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF794022),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DrinkDetailsScreen(drink: drink),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

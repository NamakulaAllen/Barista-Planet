import 'package:barista_planet/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COFFEE DRINKS',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drinks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final drinks = snapshot.data!.docs;
          final Map<String, List<DocumentSnapshot>> drinksByCategory = {};

          // Group by category
          for (var doc in drinks) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] ?? 'Uncategorized';
            drinksByCategory.putIfAbsent(category, () => []).add(doc);
          }

          return ListView.builder(
            itemCount: drinksByCategory.length,
            itemBuilder: (context, index) {
              final entry = drinksByCategory.entries.elementAt(index);

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    final categoryDrinks = entry.value
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDrinksScreen(
                          category: entry.key,
                          drinks: categoryDrinks,
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
                          Row(
                            children: [
                              Icon(
                                Icons.local_drink,
                                color: const Color(0xFF794022),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF794022),
                                ),
                              ),
                            ],
                          ),
                          Chip(
                            backgroundColor:
                                const Color(0xFF794022).withOpacity(0.1),
                            label: Text(
                              '${entry.value.length} Drinks',
                              style: const TextStyle(
                                color: Color(0xFF794022),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

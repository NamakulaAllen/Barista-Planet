import 'package:flutter/material.dart';

class CurriculumPage extends StatelessWidget {
  const CurriculumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COURSE CURRICULUM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF794022),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome to the Barista Planet Coffee Institute Course!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF794022),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This course will take you on a 4-week journey to master coffee skills and business management.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Divider(),
            CurriculumCard(
              week: "Week 1",
              title: "History of Coffee",
              description: "Learn the rich history and origin of coffee, its journey around the world, and its significance in various cultures.",
              topics: [
                "Origin and Spread of Coffee",
                "Cultural Impact of Coffee",
                "Evolution of Coffee Brewing",
              ],
              color: Color(0xFF794022),
            ),
            CurriculumCard(
              week: "Week 2",
              title: "Managing a Coffee Business",
              description: "Understand the essentials of managing a coffee shop, from inventory to customer relations and business strategy.",
              topics: [
                "Coffee Shop Setup",
                "Inventory Management",
                "Customer Service",
                "Business Strategy",
              ],
              color: Color(0xFF794022),
            ),
            CurriculumCard(
              week: "Week 3",
              title: "Coffee Brewing Techniques",
              description: "Master the preparation of various coffee types including espresso, latte, cappuccino, and more.",
              topics: [
                "Espresso Making",
                "Latte Art",
                "Cappuccino and More",
              ],
              color: Color(0xFF794022),
            ),
            CurriculumCard(
              week: "Week 4",
              title: "Cold Coffees, Mojitos, Juices, and Milkshakes",
              description: "Learn to prepare a variety of cold beverages including iced coffee, mojitos, fresh juices, and milkshakes.",
              topics: [
                "Iced Coffee Brewing",
                "Mojito Preparation",
                "Juicing Techniques",
                "Milkshake Mastery",
              ],
              color: Color(0xFF794022),
            ),
          ],
        ),
      ),
    );
  }
}

class CurriculumCard extends StatelessWidget {
  final String week;
  final String title;
  final String description;
  final List<String> topics;
  final Color color;

  const CurriculumCard({
    required this.week,
    required this.title,
    required this.description,
    required this.topics,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$week - $title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Text(
              'Key Topics:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            for (var topic in topics)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle,
                  color: color,
                ),
                title: Text(topic),
              ),
          ],
        ),
      ),
    );
  }
}

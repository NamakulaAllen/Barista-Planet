import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Course Curriculum",
          style: TextStyle(
            color: Colors.white, // Make title white
            fontWeight: FontWeight.bold, // Make title bold
          ),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Make back arrow white
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('curriculum')
            .orderBy('weekNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No curriculum found."),
            );
          }
          final weeks = snapshot.data!.docs;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                const Text(
                  "Welcome to the Barista Planet Coffee Institute Course!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF794022),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This course will take you on a 4-week journey to master coffee skills and business management.",
                  style: TextStyle(fontSize: 16),
                ),
                const Divider(),
                ...weeks.map((weekDoc) {
                  final data = weekDoc.data() as Map<String, dynamic>;
                  final topics = List<String>.from(data['topics'] ?? []);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Week Title
                            Text(
                              "${data['week']}: ${data['title']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF794022),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Description
                            Text(
                              data['description'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            // Key Topics
                            const Text(
                              "Key Topics:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF794022),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...topics.map((topic) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF794022),
                                ),
                                title: Text(topic),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

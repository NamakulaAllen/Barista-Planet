import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCurriculumScreen extends StatefulWidget {
  const AdminCurriculumScreen({super.key});

  @override
  State<AdminCurriculumScreen> createState() => _AdminCurriculumScreenState();
}

class _AdminCurriculumScreenState extends State<AdminCurriculumScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed _localCurriculum list
  final List<Map<String, dynamic>> _localCurriculum = [
    {
      'week': "Week 1",
      'title': "History of Coffee",
      'description': "Learn the rich history and origin of coffee...",
      'topics': [
        "Origin and Spread of Coffee",
        "Cultural Impact of Coffee",
        "Evolution of Coffee Brewing",
      ],
    },
    {
      'week': "Week 2",
      'title': "Managing a Coffee Business",
      'description':
          "Understand the essentials of managing a coffee shop, from inventory to customer relations and business strategy.",
      'topics': [
        "Coffee Shop Setup",
        "Inventory Management",
        "Customer Service",
        "Business Strategy",
      ],
    },
    {
      'week': "Week 3",
      'title': "Coffee Brewing Techniques",
      'description':
          "Master the preparation of various coffee types including espresso, latte, cappuccino, and more.",
      'topics': [
        "Espresso Making",
        "Latte Art",
        "Cappuccino and More",
      ],
    },
    {
      'week': "Week 4",
      'title': "Cold Coffees, Mojitos, Juices, and Milkshakes",
      'description':
          "Learn to prepare a variety of cold beverages including iced coffee, mojitos, fresh juices, and milkshakes.",
      'topics': [
        "Iced Coffee Brewing",
        "Mojito Preparation",
        "Juicing Techniques",
        "Milkshake Mastery",
      ],
    },
  ];

  // Migrate local curriculum to Firestore
  Future<void> _migrateCurriculum() async {
    try {
      final curriculumRef = _firestore.collection('curriculum');
      final batch = _firestore.batch();
      for (var week in _localCurriculum) {
        final docRef = curriculumRef.doc();
        batch.set(docRef, {
          ...week,
          'weekNumber': int.parse(week['week'].split(' ')[1]),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curriculum migrated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  // Delete a week from Firestore
  Future<void> _deleteWeek(String weekId) async {
    try {
      await _firestore.collection('curriculum').doc(weekId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Week deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting week: $e')),
      );
    }
  }

  // Show dialog to add a new week
  void _showAddWeekDialog() {
    final TextEditingController weekController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final List<TextEditingController> topicControllers = [
      TextEditingController()
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Week'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weekController,
                decoration:
                    const InputDecoration(labelText: 'Week (e.g. Week 1)'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Topics:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...topicControllers.asMap().entries.map((entry) {
                final index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Topic ${index + 1}',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          topicControllers.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton(
                onPressed: () {
                  setState(() {
                    topicControllers.add(TextEditingController());
                  });
                },
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weekController.text.isEmpty || titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Week and Title are required')),
                );
                return;
              }
              try {
                await _firestore.collection('curriculum').add({
                  'week': weekController.text,
                  'title': titleController.text,
                  'description': descController.text,
                  'topics': topicControllers.map((c) => c.text).toList(),
                  'weekNumber': int.parse(weekController.text.split(' ')[1]),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding week: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF794022),
            ),
            child: const Text('Add Week'),
          ),
        ],
      ),
    );
  }

  // Show dialog to edit an existing week
  void _showEditWeekDialog(String weekId, Map<String, dynamic> data) {
    final TextEditingController weekController =
        TextEditingController(text: data['week']);
    final TextEditingController titleController =
        TextEditingController(text: data['title']);
    final TextEditingController descController =
        TextEditingController(text: data['description']);
    final List<TextEditingController> topicControllers =
        (data['topics'] as List<dynamic>)
            .map((topic) => TextEditingController(text: topic.toString()))
            .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Week'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weekController,
                decoration: const InputDecoration(labelText: 'Week'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Topics:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...topicControllers.asMap().entries.map((entry) {
                final index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Topic ${index + 1}',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          topicControllers.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton(
                onPressed: () {
                  setState(() {
                    topicControllers.add(TextEditingController());
                  });
                },
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('curriculum').doc(weekId).update({
                  'week': weekController.text,
                  'title': titleController.text,
                  'description': descController.text,
                  'topics': topicControllers.map((c) => c.text).toList(),
                  'weekNumber': int.parse(weekController.text.split(' ')[1]),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating week: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF794022),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Curriculum'),
        backgroundColor: const Color(0xFF794022),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWeekDialog,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _migrateCurriculum,
            tooltip: 'Migrate Local Curriculum',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('curriculum')
            .orderBy('weekNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No curriculum weeks found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _migrateCurriculum,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Migrate Local Curriculum'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final week = snapshot.data!.docs[index];
              final data = week.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    '${data['week']}: ${data['title']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF794022),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['description'] ?? ''),
                          const SizedBox(height: 16),
                          const Text('Topics:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...(data['topics'] as List<dynamic>).map((topic) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 4),
                              child: Text('• $topic'),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showEditWeekDialog(week.id, data),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this week?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await _deleteWeek(week.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCurriculumScreen extends StatefulWidget {
  const AdminCurriculumScreen({super.key});

  @override
  State<AdminCurriculumScreen> createState() => _AdminCurriculumScreenState();
}

class _AdminCurriculumScreenState extends State<AdminCurriculumScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Delete a week from Firestore
  Future<void> _deleteWeek(String weekId) async {
    try {
      await _firestore.collection('curriculum').doc(weekId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Week deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF794022),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: const Text(
                'Add New Week',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weekController,
                    decoration: const InputDecoration(
                      labelText: 'Week (e.g. Week 1)',
                      hintText: 'Format: Week [number]',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Topics:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF794022),
                      )),
                  ...topicControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Topic ${index + 1}',
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF794022)),
                              ),
                              labelStyle:
                                  const TextStyle(color: Color(0xFF794022)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              topicControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        topicControllers.add(TextEditingController());
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Add Topic'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (weekController.text.isEmpty ||
                      titleController.text.isEmpty ||
                      !weekController.text.toLowerCase().startsWith('week ')) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Valid Week (e.g. Week 1) and Title are required'),
                      ),
                    );
                    return;
                  }

                  // Validate week number
                  final weekNumberStr = weekController.text.split(' ')[1];
                  final weekNumber = int.tryParse(weekNumberStr);
                  if (weekNumber == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter a valid week number (e.g. Week 1)'),
                      ),
                    );
                    return;
                  }

                  try {
                    await _firestore.collection('curriculum').add({
                      'week': weekController.text,
                      'title': titleController.text,
                      'description': descController.text,
                      'topics': topicControllers
                          .where((c) => c.text.isNotEmpty)
                          .map((c) => c.text)
                          .toList(),
                      'weekNumber': weekNumber,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding week: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Week'),
              ),
            ],
          );
        },
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF794022),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: const Text(
                'Edit Week',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weekController,
                    decoration: const InputDecoration(
                      labelText: 'Week',
                      hintText: 'Format: Week [number]',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF794022)),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF794022)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Topics:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF794022),
                      )),
                  ...topicControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Topic ${index + 1}',
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF794022)),
                              ),
                              labelStyle:
                                  const TextStyle(color: Color(0xFF794022)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              topicControllers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        topicControllers.add(TextEditingController());
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Add Topic'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (weekController.text.isEmpty ||
                      titleController.text.isEmpty ||
                      !weekController.text.toLowerCase().startsWith('week ')) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Valid Week (e.g. Week 1) and Title are required'),
                      ),
                    );
                    return;
                  }

                  // Validate week number
                  final weekNumberStr = weekController.text.split(' ')[1];
                  final weekNumber = int.tryParse(weekNumberStr);
                  if (weekNumber == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter a valid week number (e.g. Week 1)'),
                      ),
                    );
                    return;
                  }

                  try {
                    await _firestore
                        .collection('curriculum')
                        .doc(weekId)
                        .update({
                      'week': weekController.text,
                      'title': titleController.text,
                      'description': descController.text,
                      'topics': topicControllers
                          .where((c) => c.text.isNotEmpty)
                          .map((c) => c.text)
                          .toList(),
                      'weekNumber': weekNumber,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating week: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Curriculum',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF794022),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddWeekDialog,
            tooltip: 'Add New Week',
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

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading curriculum: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No curriculum weeks found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddWeekDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add First Week'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final week = snapshot.data!.docs[index];
              final data = week.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
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
                          Text(
                            data['description'] ?? 'No description',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Topics:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(data['topics'] as List<dynamic>).map((topic) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 4),
                              child: Text(
                                '• $topic',
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Last updated: ${_formatTimestamp(data['updatedAt'] ?? data['createdAt'])}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF794022)),
                                onPressed: () =>
                                    _showEditWeekDialog(week.id, data),
                                tooltip: 'Edit Week',
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF794022),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                        child: const Text(
                                          'Confirm Delete',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      titlePadding: EdgeInsets.zero,
                                      content: const Text(
                                          'Are you sure you want to delete this week? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await _deleteWeek(week.id);
                                  }
                                },
                                tooltip: 'Delete Week',
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }
}

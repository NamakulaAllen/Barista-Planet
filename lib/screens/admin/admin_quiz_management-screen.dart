import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    home: AdminQuizScreen(),
  ));
}

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addQuestion(Map<String, dynamic> question) async {
    try {
      await _firestore.collection('quiz_questions').add({
        ...question,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding question: $e')),
        );
      }
    }
  }

  Future<void> _updateQuestion(
      String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('quiz_questions').doc(docId).update({
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating question: $e')),
        );
      }
    }
  }

  Future<void> _deleteQuestion(String docId) async {
    try {
      await _firestore.collection('quiz_questions').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting question: $e')),
        );
      }
    }
  }

  void _showAddQuestionDialog() {
    final formKey = GlobalKey<FormState>();
    final questionController = TextEditingController();
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    int? correctAnswerIndex;
    String? difficulty = 'easy';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Add New Question',
              style: TextStyle(
                color: Color(0xFF794022),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value!.isEmpty ? 'Question is required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Options:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswerIndex,
                              activeColor: const Color(0xFF794022),
                              onChanged: (value) {
                                setState(() {
                                  correctAnswerIndex = value;
                                });
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Option is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['easy', 'medium', 'hard']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          difficulty = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select difficulty' : null,
                    ),
                    const SizedBox(height: 8),
                    if (correctAnswerIndex == null)
                      const Text(
                        'Please select the correct answer',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (correctAnswerIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select the correct answer')),
                      );
                      return;
                    }

                    final questionData = {
                      'question': questionController.text,
                      'options': optionControllers.map((c) => c.text).toList(),
                      'correctAnswer':
                          optionControllers[correctAnswerIndex!].text,
                      'difficulty': difficulty,
                    };

                    await _addQuestion(questionData);
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Question'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditQuestionDialog(DocumentSnapshot questionDoc) {
    final formKey = GlobalKey<FormState>();
    final data = questionDoc.data() as Map<String, dynamic>;
    final questionController = TextEditingController(text: data['question']);
    final List<TextEditingController> optionControllers =
        (data['options'] as List)
            .map((option) => TextEditingController(text: option))
            .toList();
    int? correctAnswerIndex;
    String? difficulty = data['difficulty'];

    // Find the index of the correct answer
    for (int i = 0; i < optionControllers.length; i++) {
      if (optionControllers[i].text == data['correctAnswer']) {
        correctAnswerIndex = i;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Edit Question',
              style: TextStyle(
                color: Color(0xFF794022),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value!.isEmpty ? 'Question is required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Options:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswerIndex,
                              activeColor: const Color(0xFF794022),
                              onChanged: (value) {
                                setState(() {
                                  correctAnswerIndex = value;
                                });
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Option is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['easy', 'medium', 'hard']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          difficulty = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select difficulty' : null,
                    ),
                    const SizedBox(height: 8),
                    if (correctAnswerIndex == null)
                      const Text(
                        'Please select the correct answer',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (correctAnswerIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select the correct answer')),
                      );
                      return;
                    }

                    final updatedData = {
                      'question': questionController.text,
                      'options': optionControllers.map((c) => c.text).toList(),
                      'correctAnswer':
                          optionControllers[correctAnswerIndex!].text,
                      'difficulty': difficulty,
                    };

                    await _updateQuestion(questionDoc.id, updatedData);
                    if (mounted) Navigator.pop(context);
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

  Future<void> _confirmDelete(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteQuestion(docId);
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Questions Manager',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF794022),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddQuestionDialog,
            tooltip: 'Add new question',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quiz_questions')
            .orderBy('createdAt', descending: true)
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
                  const Text('No questions found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddQuestionDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Your First Question'),
                  ),
                ],
              ),
            );
          }

          final questions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final data = question.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['question'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditQuestionDialog(question);
                              } else if (value == 'delete') {
                                _confirmDelete(question.id);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          data['difficulty'].toString().toUpperCase(),
                          style: TextStyle(
                            color: _getDifficultyColor(data['difficulty']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getDifficultyColor(data['difficulty'])
                            .withOpacity(0.2),
                        side: BorderSide.none,
                      ),
                      const SizedBox(height: 12),
                      ...(data['options'] as List).map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                option == data['correctAnswer']
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: option == data['correctAnswer']
                                    ? const Color(0xFF794022)
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(option.toString())),
                            ],
                          ),
                        );
                      }),
                    ],
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

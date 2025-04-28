import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _localQuestions = [
    {
      'question': 'What is the most popular coffee bean variety?',
      'options': ['Arabica', 'Robusta', 'Liberica', 'Excelsa'],
      'correctAnswer': 'Arabica',
      'difficulty': 'easy'
    },
    {
      'question':
          'Which brewing method uses gravity to drip water over coffee grounds?',
      'options': ['French Press', 'Pour Over', 'Espresso Machine', 'Moka Pot'],
      'correctAnswer': 'Pour Over',
      'difficulty': 'easy'
    },
    {
      'question': 'What is the term for the smell of brewed coffee?',
      'options': ['Aroma', 'Flavor', 'Body', 'Acidity'],
      'correctAnswer': 'Aroma',
      'difficulty': 'easy'
    },
    {
      'question':
          'What is the name of the traditional Ethiopian coffee ceremony?',
      'options': ['Buna', 'Gaviota', 'Café', 'Latte'],
      'correctAnswer': 'Buna',
      'difficulty': 'easy'
    },
    {
      'question':
          'Which type of coffee drink contains equal parts espresso, steamed milk, and foam?',
      'options': ['Cappuccino', 'Latte', 'Macchiato', 'Americano'],
      'correctAnswer': 'Cappuccino',
      'difficulty': 'easy'
    },
    {
      'question':
          'What is the name of the coffee-making technique that uses pressurized water?',
      'options': ['Espresso', 'Drip', 'French Press', 'Cold Brew'],
      'correctAnswer': 'Espresso',
      'difficulty': 'easy'
    },
    {
      'question': 'Which coffee drink is made with espresso and hot water?',
      'options': ['Americano', 'Latte', 'Mocha', 'Macchiato'],
      'correctAnswer': 'Americano',
      'difficulty': 'easy'
    },
    {
      'question': 'What is the term for the flavor profile of coffee?',
      'options': ['Taste', 'Profile', 'Palette', 'Notes'],
      'correctAnswer': 'Notes',
      'difficulty': 'easy'
    },
    {
      'question': 'Which country is known as the birthplace of coffee?',
      'options': ['Ethiopia', 'Brazil', 'Colombia', 'India'],
      'correctAnswer': 'Ethiopia',
      'difficulty': 'easy'
    },
    {
      'question': "What is the name of the coffee cherry's outer layer?",
      'options': ['Pulp', 'Bean', 'Seed', 'Husk'],
      'correctAnswer': 'Pulp',
      'difficulty': 'easy'
    },

    // Medium Questions (11-25)
    {
      'question':
          "What is the name of the process where coffee beans are dried in the sun?",
      'options': [
        'Natural Process',
        'Washed Process',
        'Honey Process',
        'Dry Milling'
      ],
      'correctAnswer': 'Natural Process',
      'difficulty': 'medium'
    },
    {
      'question':
          'What is the term for the bitterness found in over-extracted coffee?',
      'options': ['Burnt', 'Sharp', 'Harsh', 'Astringent'],
      'correctAnswer': 'Astringent',
      'difficulty': 'medium'
    },
    {
      'question':
          'What is the name of the tool used to measure coffee grind size?',
      'options': ['Sieve', 'Scale', 'Micrometer', 'Caliper'],
      'correctAnswer': 'Micrometer',
      'difficulty': 'medium'
    },
    {
      'question':
          'Which coffee drink is made with espresso, chocolate, and steamed milk?',
      'options': ['Mocha', 'Macchiato', 'Cappuccino', 'Latte'],
      'correctAnswer': 'Mocha',
      'difficulty': 'medium'
    },
    {
      'question':
          'What is the term for the coffee extraction process using cold water?',
      'options': [
        'Cold Brew',
        'Iced Coffee',
        'Chilled Coffee',
        'Frozen Coffee'
      ],
      'correctAnswer': 'Cold Brew',
      'difficulty': 'medium'
    },
    {
      'question': "What is the name of the coffee bean's innermost layer?",
      'options': ['Seed', 'Parchment', 'Husk', 'Chaff'],
      'correctAnswer': 'Seed',
      'difficulty': 'medium'
    },
    {
      'question':
          'Which coffee drink is topped with a dollop of whipped cream?',
      'options': ['Vienna', 'Café au Lait', 'Flat White', 'Espresso'],
      'correctAnswer': 'Vienna',
      'difficulty': 'medium'
    },
    {
      'question': "What is the term for the coffee bean's protective layer?",
      'options': ['Parchment', 'Husk', 'Chaff', 'Seed'],
      'correctAnswer': 'Parchment',
      'difficulty': 'medium'
    },
    {
      'question':
          'Which brewing method involves steeping coffee grounds in hot water?',
      'options': ['French Press', 'Pour Over', 'Espresso', 'Cold Brew'],
      'correctAnswer': 'French Press',
      'difficulty': 'medium'
    },
    {
      'question':
          'What is the name of the process where coffee beans are fermented?',
      'options': [
        'Washed Process',
        'Natural Process',
        'Honey Process',
        'Dry Milling'
      ],
      'correctAnswer': 'Washed Process',
      'difficulty': 'medium'
    },
    {
      'question':
          'What is the term for the sweetness found in well-balanced coffee?',
      'options': ['Fruity', 'Nutty', 'Chocolatey', 'Caramelly'],
      'correctAnswer': 'Caramelly',
      'difficulty': 'medium'
    },
    {
      'question':
          'Which coffee drink is made with espresso and a small amount of steamed milk?',
      'options': ['Macchiato', 'Cappuccino', 'Latte', 'Flat White'],
      'correctAnswer': 'Macchiato',
      'difficulty': 'medium'
    },
    {
      'question': 'What is the ideal water temperature for brewing coffee?',
      'options': ['80-85°C', '90-96°C', '70-75°C', '100°C'],
      'correctAnswer': '90-96°C',
      'difficulty': 'medium'
    },
    {
      'question': 'Which country is the largest producer of coffee?',
      'options': ['Brazil', 'Vietnam', 'Colombia', 'Ethiopia'],
      'correctAnswer': 'Brazil',
      'difficulty': 'medium'
    },
    {
      'question': 'What is the term for unroasted coffee beans?',
      'options': ['Green beans', 'Raw beans', 'Fresh beans', 'Natural beans'],
      'correctAnswer': 'Green beans',
      'difficulty': 'medium'
    },

    // Hard Questions (26-50)
    {
      'question':
          "What is the name of the coffee bean's genetic classification?",
      'options': ['Species', 'Varietal', 'Blend', 'Cultivar'],
      'correctAnswer': 'Varietal',
      'difficulty': 'hard'
    },
    {
      'question': 'Which coffee region is known for its high-altitude farms?',
      'options': ['Colombia', 'Ethiopia', 'Brazil', 'Vietnam'],
      'correctAnswer': 'Ethiopia',
      'difficulty': 'hard'
    },
    {
      'question':
          'What is the term for the roasting process that brings out fruity notes?',
      'options': ['Light Roast', 'Medium Roast', 'Dark Roast', 'City Roast'],
      'correctAnswer': 'Light Roast',
      'difficulty': 'hard'
    },
    {
      'question': 'What is the name of the tool used to tamp espresso grounds?',
      'options': ['Tamper', 'Scoop', 'Knockbox', 'Portafilter'],
      'correctAnswer': 'Tamper',
      'difficulty': 'hard'
    },
    {
      'question': 'Which coffee drink is served with a glass of water?',
      'options': ['Espresso', 'Cappuccino', 'Latte', 'Americano'],
      'correctAnswer': 'Espresso',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's drying process?",
      'options': ['Sun Drying', 'Machine Drying', 'Air Drying', 'Fermentation'],
      'correctAnswer': 'Sun Drying',
      'difficulty': 'hard'
    },
    {
      'question': 'Which brewing method uses a vacuum seal?',
      'options': ['Siphon', 'French Press', 'Pour Over', 'Espresso'],
      'correctAnswer': 'Siphon',
      'difficulty': 'hard'
    },
    {
      'question':
          "What is the term for the coffee bean's natural sugar content?",
      'options': ['Sucrose', 'Fructose', 'Glucose', 'Maltose'],
      'correctAnswer': 'Sucrose',
      'difficulty': 'hard'
    },
    {
      'question': 'Which coffee drink is made with espresso and cold milk?',
      'options': ['Iced Latte', 'Cold Brew', 'Nitro Coffee', 'Frappe'],
      'correctAnswer': 'Iced Latte',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's roast profile?",
      'options': ['Profile', 'Curve', 'Graph', 'Chart'],
      'correctAnswer': 'Profile',
      'difficulty': 'hard'
    },
    {
      'question': "What is the name of the coffee bean's outermost layer?",
      'options': ['Husk', 'Parchment', 'Chaff', 'Seed'],
      'correctAnswer': 'Husk',
      'difficulty': 'hard'
    },
    {
      'question': 'Which brewing method uses a paper filter?',
      'options': ['Pour Over', 'French Press', 'Espresso', 'Moka Pot'],
      'correctAnswer': 'Pour Over',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's moisture content?",
      'options': ['Hydration', 'Humidity', 'Moisture', 'Saturation'],
      'correctAnswer': 'Moisture',
      'difficulty': 'hard'
    },
    {
      'question': 'Which coffee drink is made with espresso and steamed milk?',
      'options': ['Latte', 'Cappuccino', 'Macchiato', 'Americano'],
      'correctAnswer': 'Latte',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's genetic diversity?",
      'options': ['Variety', 'Blend', 'Cultivar', 'Species'],
      'correctAnswer': 'Variety',
      'difficulty': 'hard'
    },
    {
      'question':
          "What is the name of the process where coffee beans are roasted?",
      'options': ['Roasting', 'Baking', 'Grilling', 'Frying'],
      'correctAnswer': 'Roasting',
      'difficulty': 'hard'
    },
    {
      'question':
          'Which coffee drink is made with espresso and a hint of milk foam?',
      'options': ['Macchiato', 'Cappuccino', 'Latte', 'Flat White'],
      'correctAnswer': 'Macchiato',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's genetic mutation?",
      'options': ['Mutation', 'Varietal', 'Blend', 'Species'],
      'correctAnswer': 'Mutation',
      'difficulty': 'hard'
    },
    {
      'question': 'Which brewing method uses a metal filter?',
      'options': ['French Press', 'Pour Over', 'Espresso', 'Moka Pot'],
      'correctAnswer': 'French Press',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's genetic crossbreed?",
      'options': ['Hybrid', 'Varietal', 'Blend', 'Species'],
      'correctAnswer': 'Hybrid',
      'difficulty': 'hard'
    },
    {
      'question': 'Which coffee drink is made with espresso and chocolate?',
      'options': ['Mocha', 'Macchiato', 'Cappuccino', 'Latte'],
      'correctAnswer': 'Mocha',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's genetic purity?",
      'options': ['Purebred', 'Varietal', 'Blend', 'Species'],
      'correctAnswer': 'Purebred',
      'difficulty': 'hard'
    },
    {
      'question': 'Which brewing method uses a cloth filter?',
      'options': ['Pour Over', 'French Press', 'Espresso', 'Moka Pot'],
      'correctAnswer': 'Pour Over',
      'difficulty': 'hard'
    },
    {
      'question': "What is the term for the coffee bean's genetic stability?",
      'options': ['Stable', 'Varietal', 'Blend', 'Species'],
      'correctAnswer': 'Stable',
      'difficulty': 'hard'
    },
    {
      'question':
          'What is the name of the scale used to measure coffee quality?',
      'options': [
        'SCAA Scale',
        'Coffee Taster Scale',
        'Q Grader Scale',
        'Cupping Scale'
      ],
      'correctAnswer': 'Q Grader Scale',
      'difficulty': 'hard'
    }
    // Add all your other questions here
  ];

  Future<void> _migrateQuestions() async {
    try {
      final questionsRef = _firestore.collection('quiz_questions');
      final batch = _firestore.batch();

      for (var question in _localQuestions) {
        final docRef = questionsRef.doc();
        batch.set(docRef, {
          ...question,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questions migrated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await _firestore.collection('quiz_questions').doc(questionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting question: $e')),
      );
    }
  }

  void _showAddQuestionDialog() {
    final TextEditingController questionController = TextEditingController();
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    String? correctAnswer;
    String? difficulty = 'easy';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text('Options:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...optionControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Row(
                      children: [
                        Radio<String>(
                          value: 'Option ${index + 1}',
                          groupValue: correctAnswer,
                          onChanged: (value) {
                            setState(() {
                              correctAnswer = entry.value.text;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                            ),
                            onChanged: (value) {
                              if (correctAnswer == 'Option ${index + 1}') {
                                setState(() {
                                  correctAnswer = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
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
                  if (questionController.text.isEmpty ||
                      optionControllers.any((c) => c.text.isEmpty) ||
                      correctAnswer == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  try {
                    await _firestore.collection('quiz_questions').add({
                      'question': questionController.text,
                      'options': optionControllers.map((c) => c.text).toList(),
                      'correctAnswer': correctAnswer,
                      'difficulty': difficulty,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding question: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                ),
                child: const Text('Add Question'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditQuestionDialog(String questionId, Map<String, dynamic> data) {
    final TextEditingController questionController =
        TextEditingController(text: data['question']);
    final List<TextEditingController> optionControllers =
        (data['options'] as List<dynamic>)
            .map((option) => TextEditingController(text: option.toString()))
            .toList();
    String? correctAnswer = data['correctAnswer'];
    String? difficulty = data['difficulty'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text('Options:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...optionControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Row(
                      children: [
                        Radio<String>(
                          value: entry.value.text,
                          groupValue: correctAnswer,
                          onChanged: (value) {
                            setState(() {
                              correctAnswer = value;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                            ),
                            onChanged: (value) {
                              if (correctAnswer == entry.value.text) {
                                setState(() {
                                  correctAnswer = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
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
                    await _firestore
                        .collection('quiz_questions')
                        .doc(questionId)
                        .update({
                      'question': questionController.text,
                      'options': optionControllers.map((c) => c.text).toList(),
                      'correctAnswer': correctAnswer,
                      'difficulty': difficulty,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating question: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
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
        title: const Text('Manage Quiz Questions'),
        backgroundColor: const Color(0xFF794022),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddQuestionDialog,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _migrateQuestions,
            tooltip: 'Migrate Local Questions',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quiz_questions').snapshots(),
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
                    onPressed: _migrateQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Migrate Local Questions'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final question = snapshot.data!.docs[index];
              final data = question.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['question'] ?? ''),
                  subtitle: Text(
                    'Difficulty: ${(data['difficulty'] ?? 'unknown').toString().toUpperCase()}',
                    style: TextStyle(
                      color: _getDifficultyColor(data['difficulty']),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditQuestionDialog(question.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this question?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _deleteQuestion(question.id);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showQuestionDetails(context, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showQuestionDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Question Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['question'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Difficulty: ${(data['difficulty'] ?? 'unknown').toString().toUpperCase()}',
                style: TextStyle(
                  color: _getDifficultyColor(data['difficulty']),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Options:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...(data['options'] as List<dynamic>).map((option) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4),
                  child: Row(
                    children: [
                      option == data['correctAnswer']
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.radio_button_unchecked,
                              color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(option.toString()),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() {
  runApp(const MaterialApp(home: CoffeeQuizScreen()));
}

class CoffeeQuizScreen extends StatefulWidget {
  const CoffeeQuizScreen({super.key});

  @override
  State<CoffeeQuizScreen> createState() => _CoffeeQuizScreenState();
}

class _CoffeeQuizScreenState extends State<CoffeeQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allQuestions = [];
  bool isLoading = true;
  String? errorMessage;

  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool showCorrectAnswer = false;
  int timeLeft = 10;
  Timer? _timer;
  List<Map<String, dynamic>> userAnswers = [];

  // All 50 questions (Easy 1-10, Medium 11-25, Hard 26-50)
  final List<Map<String, dynamic>> hardcodedQuestions = [
    // Easy Questions (1-10)
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
  ];

  @override
  void initState() {
    super.initState();
    _initializeFirestoreData().then((_) => _initializeQuiz());
  }

  Future<void> _initializeFirestoreData() async {
    try {
      final productsRef = _firestore.collection('products');

      // Create Coffee Quiz product if it doesn't exist
      final coffeeQuizDoc = await productsRef.doc('Coffee Quiz').get();
      if (!coffeeQuizDoc.exists) {
        await productsRef.doc('Coffee Quiz').set({
          'name': 'Coffee Quiz',
          'type': 'quiz',
          'description': 'Test your coffee knowledge',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add questions subcollection
        final batch = _firestore.batch();
        final questionsRef =
            productsRef.doc('Coffee Quiz').collection('questions');

        for (var question in hardcodedQuestions) {
          final docRef = questionsRef.doc();
          batch.set(docRef, {
            ...question,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error initializing Firestore data: $e');
    }
  }

  Future<void> _pushQuestionsToFirebase() async {
    try {
      final productsRef = _firestore.collection('products');
      final questionsRef =
          productsRef.doc('Coffee Quiz').collection('questions');

      // First delete all existing questions
      final querySnapshot = await questionsRef.get();
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Add all questions
      final addBatch = _firestore.batch();
      for (var question in hardcodedQuestions) {
        final docRef = questionsRef.doc();
        addBatch.set(docRef, {
          ...question,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await addBatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Questions pushed to Firebase successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pushing questions: $e')),
      );
    }
  }

  Future<void> _initializeQuiz() async {
    try {
      await _fetchQuestions();
      if (allQuestions.isEmpty) {
        setState(() {
          allQuestions = hardcodedQuestions;
          errorMessage = 'Using local questions (no data from server)';
        });
      }
      _startTimer();
    } catch (e) {
      setState(() {
        allQuestions = hardcodedQuestions;
        errorMessage = 'Error loading questions: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .doc('Coffee Quiz')
          .collection('questions')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          allQuestions = querySnapshot.docs.map((doc) => doc.data()).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    timeLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _timer?.cancel();
          _nextQuestion(false);
        }
      });
    });
  }

  void _nextQuestion(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        score += 1;
      });
    }

    userAnswers.add({
      'question': allQuestions[currentQuestionIndex]['question'],
      'selectedAnswer': selectedAnswer,
      'correctAnswer': allQuestions[currentQuestionIndex]['correctAnswer'],
      'wasCorrect': isCorrect,
    });

    setState(() {
      showCorrectAnswer = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestionIndex < allQuestions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showCorrectAnswer = false;
          _startTimer();
        });
      } else {
        _timer?.cancel();
        _showQuizCompletionDialog();
      }
    });
  }

  Color _getAnswerColor(String option) {
    if (!showCorrectAnswer) return Colors.white;
    if (option == allQuestions[currentQuestionIndex]['correctAnswer']) {
      return Colors.green;
    }
    if (option == selectedAnswer) return Colors.red;
    return Colors.white;
  }

  void _showQuizCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text('Your score: $score/${allQuestions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetQuiz();
              },
              child: const Text('Restart Quiz'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReviewScreen(userAnswers: userAnswers),
                  ),
                );
              },
              child: const Text('Review Answers'),
            ),
            if (FirebaseAuth.instance.currentUser?.uid == 'your-admin-uid')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pushQuestionsToFirebase();
                },
                child: const Text('Push Questions to Firebase'),
              ),
          ],
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      showCorrectAnswer = false;
      timeLeft = 10;
      userAnswers.clear();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coffee Quiz',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (FirebaseAuth.instance.currentUser?.uid == 'your-admin-uid')
            IconButton(
              icon: const Icon(Icons.cloud_upload, color: Colors.white),
              onPressed: _pushQuestionsToFirebase,
              tooltip: 'Push Questions to Firebase',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No questions available'),
                      if (errorMessage != null)
                        Text(errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _initializeQuiz,
                        child: const Text('Retry'),
                      ),
                      ElevatedButton(
                        onPressed: _pushQuestionsToFirebase,
                        child: const Text('Push Questions to Firebase'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (currentQuestionIndex + 1) / allQuestions.length,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.brown[700]!),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Time Left: $timeLeft seconds',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Question ${currentQuestionIndex + 1}/${allQuestions.length}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          allQuestions[currentQuestionIndex]['question'],
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...allQuestions[currentQuestionIndex]['options']
                          .map<Widget>((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (!showCorrectAnswer) {
                                setState(() {
                                  selectedAnswer = option;
                                });
                                _nextQuestion(option ==
                                    allQuestions[currentQuestionIndex]
                                        ['correctAnswer']);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getAnswerColor(option),
                              foregroundColor: Colors.brown[700],
                              minimumSize: const Size(double.infinity, 50),
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              option,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        );
                      }).toList(),
                      if (showCorrectAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Correct Answer:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                allQuestions[currentQuestionIndex]
                                    ['correctAnswer'],
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Text(
                        'Score: $score/${allQuestions.length}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> userAnswers;

  const ReviewScreen({super.key, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Answers',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: userAnswers.length,
        itemBuilder: (context, index) {
          final answer = userAnswers[index];
          final isCorrect = answer['wasCorrect'] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}: ${answer['question']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Answer: ${answer['selectedAnswer'] ?? "No answer"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct Answer: ${answer['correctAnswer']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoffeeQuizScreen extends StatefulWidget {
  const CoffeeQuizScreen({super.key});

  @override
  State<CoffeeQuizScreen> createState() => _CoffeeQuizScreenState();
}

class _CoffeeQuizScreenState extends State<CoffeeQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> allQuestions = [];
  bool isLoading = true;
  String? errorMessage;
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool showCorrectAnswer = false;
  bool showReview = false;
  int timeLeft = 10;
  Timer? _timer;
  List<Map<String, dynamic>> userAnswers = [];
  StreamSubscription<QuerySnapshot>? _questionsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    try {
      // Set up real-time listener for questions
      _questionsSubscription = _firestore
          .collection('quiz_questions')
          .orderBy('createdAt')
          .snapshots()
          .listen((querySnapshot) {
        if (mounted) {
          setState(() {
            allQuestions = querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'question': data['question'] ?? '',
                'options': List<String>.from(data['options'] ?? []),
                'correctAnswer': data['correctAnswer'] ?? '',
                'difficulty': data['difficulty'] ?? 'medium',
              };
            }).toList();
            isLoading = false;
          });
          if (!showReview && allQuestions.isNotEmpty) {
            _startTimer();
          }
        }
      }, onError: (e) {
        if (mounted) {
          setState(() {
            errorMessage = 'Error loading questions: ${e.toString()}';
            isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Initialization error: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    timeLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _timer?.cancel();
          if (!showCorrectAnswer && !showReview) {
            _nextQuestion(false);
          }
        }
      });
    });
  }

  void _nextQuestion(bool isCorrect) {
    _timer?.cancel();

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
      if (!mounted) return;

      if (currentQuestionIndex < allQuestions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showCorrectAnswer = false;
          timeLeft = 10;
          _startTimer();
        });
      } else {
        setState(() {
          showReview = true;
        });
      }
    });
  }

  void _resetQuiz() {
    _timer?.cancel();
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      showCorrectAnswer = false;
      showReview = false;
      timeLeft = 10;
      userAnswers.clear();
    });
    if (allQuestions.isNotEmpty) {
      _startTimer();
    }
  }

  Color _getAnswerColor(String option) {
    if (!showCorrectAnswer) return Colors.white;
    if (option == allQuestions[currentQuestionIndex]['correctAnswer']) {
      return Colors.green.shade100;
    }
    if (option == selectedAnswer &&
        option != allQuestions[currentQuestionIndex]['correctAnswer']) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COFFEE QUIZ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF794022),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        onPressed: _resetQuiz,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : !showReview
                  ? _buildQuizContent()
                  : _buildReviewPage(),
    );
  }

  Widget _buildQuizContent() {
    final currentQuestion = allQuestions[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / allQuestions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF794022),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Time Left: $timeLeft seconds',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Question ${currentQuestionIndex + 1}/${allQuestions.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 24),
          ...currentQuestion['options'].map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!showCorrectAnswer && selectedAnswer == null) {
                      setState(() {
                        selectedAnswer = option;
                      });
                      _nextQuestion(option == currentQuestion['correctAnswer']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getAnswerColor(option),
                    foregroundColor: Colors.black,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                    currentQuestion['correctAnswer'],
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Text(
            'Score: $score/${allQuestions.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz Completed!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF794022),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your Score: $score/${allQuestions.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Review Your Answers:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF794022),
            ),
          ),
          const SizedBox(height: 10),
          ...userAnswers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            final isCorrect = answer['wasCorrect'] ?? false;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Correct Answer: ${answer['correctAnswer']}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _resetQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794022),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Restart Quiz', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

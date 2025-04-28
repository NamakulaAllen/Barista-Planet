import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeQuizQuestion {
  String? id;
  String question;
  List<String> options;
  String correctAnswer;
  String difficulty;
  String createdBy;
  DateTime? createdAt;

  CoffeeQuizQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.difficulty = 'medium',
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore document
  factory CoffeeQuizQuestion.fromMap(Map<String, dynamic> map, String id) {
    return CoffeeQuizQuestion(
      id: id,
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
      difficulty: map['difficulty'] ?? 'medium',
      createdBy: map['createdBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

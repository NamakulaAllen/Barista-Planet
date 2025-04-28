// class AddEditQuestionScreen extends StatefulWidget {
//   final Map<String, dynamic>? question;
//   final String? questionId;
//   final String difficulty;

//   const AddEditQuestionScreen({
//     super.key,
//     this.question,
//     this.questionId,
//     required this.difficulty,
//   });

//   @override
//   State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
// }

// class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _questionController = TextEditingController();
//   final List<TextEditingController> _optionControllers = [];
//   final _correctAnswerController = TextEditingController();
//   String _selectedDifficulty = 'easy';

//   @override
//   void initState() {
//     super.initState();
//     _selectedDifficulty = widget.difficulty;

//     if (widget.question != null) {
//       _questionController.text = widget.question!['question'] ?? '';
//       _correctAnswerController.text = widget.question!['correctAnswer'] ?? '';

//       final options = widget.question!['options'] as List<dynamic>? ?? [];
//       _optionControllers.addAll(
//         options.map((option) => TextEditingController(text: option.toString())),
//       );
//     } else {
//       // Add 4 empty option fields by default
//       for (int i = 0; i < 4; i++) {
//         _optionControllers.add(TextEditingController());
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _questionController.dispose();
//     _correctAnswerController.dispose();
//     for (var controller in _optionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.question == null ? 'Add Question' : 'Edit Question'),
//         backgroundColor: const Color(0xFF794022),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _questionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Question',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a question';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               _buildDifficultyDropdown(),
//               const SizedBox(height: 16),
//               const Text(
//                 'Options',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               ..._buildOptionFields(),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _correctAnswerController.text.isEmpty
//                     ? null
//                     : _correctAnswerController.text,
//                 decoration: const InputDecoration(
//                   labelText: 'Correct Answer',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _optionControllers
//                     .where((controller) => controller.text.isNotEmpty)
//                     .map((controller) {
//                   return DropdownMenuItem<String>(
//                     value: controller.text,
//                     child: Text(controller.text),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   _correctAnswerController.text = value ?? '';
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select the correct answer';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _saveQuestion,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF794022),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child:
//                     const Text('Save', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDifficultyDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedDifficulty,
//       decoration: const InputDecoration(
//         labelText: 'Difficulty',
//         border: OutlineInputBorder(),
//       ),
//       items: const [
//         DropdownMenuItem(
//           value: 'easy',
//           child: Text('Easy'),
//         ),
//         DropdownMenuItem(
//           value: 'medium',
//           child: Text('Medium'),
//         ),
//         DropdownMenuItem(
//           value: 'hard',
//           child: Text('Hard'),
//         ),
//       ],
//       onChanged: (value) {
//         setState(() {
//           _selectedDifficulty = value!;
//         });
//       },
//     );
//   }

//   List<Widget> _buildOptionFields() {
//     return List<Widget>.generate(_optionControllers.length, (index) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 8),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _optionControllers[index],
//                 decoration: InputDecoration(
//                   labelText: 'Option ${index + 1}',
//                   border: const OutlineInputBorder(),
//                 ),
//                 onChanged: (value) {
//                   if (_correctAnswerController.text == value) {
//                     _correctAnswerController.text = '';
//                   }
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an option';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             if (_optionControllers.length > 1)
//               IconButton(
//                 icon: const Icon(Icons.remove_circle, color: Colors.red),
//                 onPressed: () => _removeOptionField(index),
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   void _removeOptionField(int index) {
//     if (_optionControllers.length > 1) {
//       setState(() {
//         if (_correctAnswerController.text == _optionControllers[index].text) {
//           _correctAnswerController.text = '';
//         }
//         _optionControllers[index].dispose();
//         _optionControllers.removeAt(index);
//       });
//     }
//   }

//   Future<void> _saveQuestion() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final options = _optionControllers
//             .map((controller) => controller.text)
//             .where((option) => option.isNotEmpty)
//             .toList();

//         if (options.length < 2) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please provide at least 2 options')),
//           );
//           return;
//         }

//         if (!options.contains(_correctAnswerController.text)) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Correct answer must match one of the options')),
//           );
//           return;
//         }

//         final questionData = {
//           'question': _questionController.text,
//           'options': options,
//           'correctAnswer': _correctAnswerController.text,
//           'difficulty': _selectedDifficulty,
//           'updatedAt': FieldValue.serverTimestamp(),
//         };

//         final questionsRef = FirebaseFirestore.instance
//             .collection('products')
//             .doc('Coffee Quiz')
//             .collection('questions');

//         if (widget.questionId == null) {
//           // Add new question
//           questionData['createdAt'] = FieldValue.serverTimestamp();
//           await questionsRef.add(questionData);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Question added successfully')),
//           );
//         } else {
//           // Update existing question
//           await questionsRef.doc(widget.questionId).update(questionData);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Question updated successfully')),
//           );
//         }

//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving question: $e')),
//         );
//       }
//     }
//   }
// }

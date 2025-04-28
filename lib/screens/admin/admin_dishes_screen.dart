import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminDishesScreen extends StatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  State<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends State<AdminDishesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _drinkControllers = [];

  // Hardcoded local dishes
  final List<Map<String, dynamic>> _localDishes = [
    {
      'name': 'Cappuccino Cup',
      'image': 'assets/images/cool1.jpg',
      'description':
          'A wide-rimmed cup designed to hold frothy cappuccinos, enhancing aroma and flavor.',
      'drinks': ['Cappuccino', 'Flat White'],
    },
    {
      'name': 'Collins Glass',
      'image': 'assets/images/cap2.jpg',
      'description':
          'A tall, narrow glass ideal for iced coffee or coffee-based cocktails.',
      'drinks': ['Iced Coffee', 'Coffee Mojito'],
    },
    {
      'name': 'Espresso Cup',
      'image': 'assets/images/cap3.jpg',
      'description':
          'A small, thick-walled cup that preserves heat and enhances the crema of espresso.',
      'drinks': ['Espresso', 'Macchiato', 'Doppio'],
    },
    {
      'name': 'Coupette Glass',
      'image': 'assets/images/de.jpg',
      'description':
          'A wide, shallow glass perfect for serving espresso martinis or coffee-based cocktails.',
      'drinks': ['Espresso Martini', 'Irish Coffee'],
    },
    {
      'name': 'Latte Glass',
      'image': 'assets/images/cap5.jpg',
      'description':
          'A tall, heat-resistant glass used for serving layered lattes and specialty coffee drinks.',
      'drinks': ['Latte', 'Caramel Macchiato'],
    },
    {
      'name': 'Demitasse Cup',
      'image': 'assets/images/cap6.jpg',
      'description':
          'A small cup, usually 2-3 oz, ideal for serving strong coffee like espresso or Turkish coffee.',
      'drinks': ['Espresso', 'Turkish Coffee', 'Ristretto'],
    },
    {
      'name': 'Irish Coffee Glass',
      'image': 'assets/images/irish.jpg',
      'description':
          'A heat-resistant glass with a handle, designed for serving hot Irish coffee with whiskey and cream.',
      'drinks': ['Irish Coffee', 'Baileys Coffee'],
    },
    {
      'name': 'Tiki Mug',
      'image': 'assets/images/cup7.jpg',
      'description':
          'A decorative mug used for serving coffee-based cocktails, adding a unique presentation element.',
      'drinks': ['Coffee Colada', 'Tiki Espresso'],
    },
    {
      'name': 'Cortado Glass',
      'image': 'assets/images/cup8.jpg',
      'description':
          'A small glass designed for cortados, balancing the espresso with an equal amount of steamed milk.',
      'drinks': ['Cortado', 'Piccolo Latte'],
    },
    {
      'name': 'Double Walled Glass',
      'image': 'assets/images/cup9.jpg',
      'description':
          'An insulated glass that keeps coffee hot while remaining cool to the touch, ideal for modern espresso drinks.',
      'drinks': ['Espresso', 'Flat White', 'Americano'],
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _drinkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_selectedImage == null) return '';
    final ref = _storage
        .ref()
        .child('dishes/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(_selectedImage!);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _addDish() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final imageUrl = await _uploadImage();
      final drinks = _drinkControllers
          .map((c) => c.text)
          .where((d) => d.isNotEmpty)
          .toList();
      await _firestore.collection('dishes').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': imageUrl,
        'drinks': drinks,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dish added successfully')),
      );
      // Reset form
      _nameController.clear();
      _descriptionController.clear();
      for (var controller in _drinkControllers) {
        controller.clear();
      }
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding dish: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addDrinkField() {
    setState(() {
      _drinkControllers.add(TextEditingController());
    });
  }

  void _removeDrinkField(int index) {
    setState(() {
      _drinkControllers.removeAt(index);
    });
  }

  Future<void> _migrateDishes() async {
    try {
      final dishesRef = _firestore.collection('dishes');
      final batch = _firestore.batch();

      for (final dish in _localDishes) {
        final docRef = dishesRef.doc();
        batch.set(docRef, {
          ...dish,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dishes migrated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  Future<void> _deleteDish(String dishId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: const Text('Are you sure you want to delete this dish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _firestore.collection('dishes').doc(dishId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting dish: $e')),
        );
      }
    }
  }

  void _showAddDishDialog() {
    _selectedImage = null;
    _nameController.clear();
    _descriptionController.clear();
    _drinkControllers.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Dish'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 50),
                                  Text('Add Image'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Dish Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Compatible Drinks:'),
                    ..._drinkControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: 'Drink Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeDrinkField(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: _addDrinkField,
                      child: const Text('Add Drink'),
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
                  onPressed: _isLoading ? null : _addDish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF794022),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Dish'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dishes'),
        backgroundColor: const Color(0xFF794022),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDishDialog,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _migrateDishes,
            tooltip: 'Migrate Local Dishes',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('dishes').orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No dishes found in Firestore'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _migrateDishes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Migrate Local Dishes'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final dish = snapshot.data!.docs[index];
              final data = dish.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['image'] != null
                      ? Image.network(data['image'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.restaurant, size: 50),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDishDialog(dish.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDish(dish.id),
                      ),
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

  void _showEditDishDialog(String dishId, Map<String, dynamic> data) {
    // Implement edit functionality similar to Add Dish Dialog
  }
}

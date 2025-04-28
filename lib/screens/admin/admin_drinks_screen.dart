import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDrinksScreen extends StatefulWidget {
  const AdminDrinksScreen({super.key});

  @override
  State<AdminDrinksScreen> createState() => _AdminDrinksScreenState();
}

class _AdminDrinksScreenState extends State<AdminDrinksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ImgBB API Key (replace with your actual API key)
  final String imgbbApiKey =
      'https://api.imgbb.com/1/upload?key=f53f2b2d663578cc4c7ddba11a81a8dc';

  // Local drinks data
  final Map<String, List<Map<String, dynamic>>> _localDrinks = {
    'Black Coffee': [
      {
        'name': 'Espresso',
        'image': 'assets/images/e1.jpg',
        'ingredients': {'Espresso': '1 shot'},
        'preparation':
            'Brew a single shot of espresso using an espresso machine.',
      },
      {
        'name': 'Americano',
        'image': 'assets/images/d1.jpg',
        'ingredients': {'Espresso': '1 shot', 'Hot Water': '6 oz'},
        'preparation': 'Brew a shot of espresso and dilute it with hot water.',
      },
    ],
    'Cold Coffee': [
      {
        'name': 'Iced Coffee',
        'image': 'assets/images/e3.jpg',
        'ingredients': {
          'Coffee': '6 oz',
          'Ice Cubes': 'As needed',
          'Sugar': 'To taste'
        },
        'preparation':
            'Brew hot coffee, cool it down, then add ice cubes and sugar.',
      },
      {
        'name': 'Iced Latte',
        'image': 'assets/images/e4.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Ice Cubes': 'As needed'
        },
        'preparation': 'Brew espresso, pour over ice, and add milk.',
      },
    ],
    'Blended Coffee': [
      {
        'name': 'Mocha Frappuccino',
        'image': 'assets/images/e5.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': '1 cup',
          'Chocolate Syrup': '2 tbsp',
          'Milk': '1/2 cup'
        },
        'preparation':
            'Blend espresso, chocolate syrup, milk, and ice until smooth.',
      },
      {
        'name': 'Caramel Frappuccino',
        'image': 'assets/images/e6.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': '1 cup',
          'Caramel Syrup': '2 tbsp',
          'Milk': '1/2 cup'
        },
        'preparation':
            'Blend espresso, caramel syrup, milk, and ice until smooth.',
      },
    ],
    'Latte': [
      {
        'name': 'Vanilla Latte',
        'image': 'assets/images/e7.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Vanilla Syrup': '1 tbsp'
        },
        'preparation':
            'Brew espresso and mix with steamed milk and vanilla syrup.',
      },
      {
        'name': 'Cinnamon Latte',
        'image': 'assets/images/e8.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Cinnamon Syrup': '1 tbsp'
        },
        'preparation':
            'Brew espresso and mix with steamed milk and cinnamon syrup.',
      },
    ],
    'Mocha': [
      {
        'name': 'Classic Mocha',
        'image': 'assets/images/d2.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Chocolate Syrup': '2 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, add chocolate syrup, and mix with steamed milk.',
      },
      {
        'name': 'White Mocha',
        'image': 'assets/images/e10.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'White Chocolate Syrup': '2 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, add white chocolate syrup, and mix with steamed milk.',
      },
    ],
    'Iced Latte': [
      {
        'name': 'Iced Vanilla Latte',
        'image': 'assets/images/f1.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': 'As needed',
          'Vanilla Syrup': '1 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, pour over ice, and add vanilla syrup and milk.',
      },
      {
        'name': 'Iced Cinnamon Latte',
        'image': 'assets/images/f2.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': 'As needed',
          'Cinnamon Syrup': '1 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, pour over ice, and add cinnamon syrup and milk.',
      },
    ],
    'Specialty Coffee': [
      {
        'name': 'Affogato',
        'image': 'assets/images/f3.jpg',
        'ingredients': {'Espresso': '1 shot', 'Vanilla Ice Cream': '1 scoop'},
        'preparation':
            'Brew espresso and pour it over a scoop of vanilla ice cream.',
      },
      {
        'name': 'Cortado',
        'image': 'assets/images/f4.jpg',
        'ingredients': {'Espresso': '1 shot', 'Steamed Milk': '1 oz'},
        'preparation': 'Brew espresso and add a small amount of steamed milk.',
      },
    ],
    'Decaf Coffee': [
      {
        'name': 'Decaf Espresso',
        'image': 'assets/images/f5.jpg',
        'ingredients': {'Decaf Espresso': '1 shot'},
        'preparation': 'Brew a decaffeinated espresso shot.',
      },
      {
        'name': 'Decaf Latte',
        'image': 'assets/images/f5.jpg',
        'ingredients': {'Decaf Espresso': '1 shot', 'Milk': '6 oz'},
        'preparation': 'Brew decaf espresso and mix with steamed milk.',
      },
    ],
    'Hot Chocolate': [
      {
        'name': 'Classic Hot Chocolate',
        'image': 'assets/images/f6.jpg',
        'ingredients': {'Milk': '1 cup', 'Chocolate Syrup': '2 tbsp'},
        'preparation': 'Heat milk and mix in chocolate syrup.',
      },
      {
        'name': 'White Hot Chocolate',
        'image': 'assets/images/f7.jpg',
        'ingredients': {'Milk': '1 cup', 'White Chocolate Syrup': '2 tbsp'},
        'preparation': 'Heat milk and mix in white chocolate syrup.',
      },
    ],
    'Tea': [
      {
        'name': 'Chai Latte',
        'image': 'assets/images/f8.jpg',
        'ingredients': {
          'Black Tea': '1 bag',
          'Milk': '6 oz',
          'Chai Syrup': '1 tbsp'
        },
        'preparation':
            'Brew black tea and mix with steamed milk and chai syrup.',
      },
      {
        'name': 'Green Tea Latte',
        'image': 'assets/images/f9.jpg',
        'ingredients': {
          'Green Tea': '1 bag',
          'Milk': '6 oz',
          'Honey': '1 tbsp'
        },
        'preparation': 'Brew green tea and mix with steamed milk and honey.',
      },
    ],
  };

  // Upload image to ImgBB and return the URL
  Future<String?> _uploadImageToImgBB(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );
      request.fields['key'] = imgbbApiKey;
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['data']['url'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to upload image. Status code: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  // Migrate local drinks to Firestore
  Future<void> _migrateDrinks() async {
    try {
      final drinksRef = _firestore.collection('drinks');
      final batch = _firestore.batch();

      // Convert nested map structure to Firestore documents
      for (var category in _localDrinks.keys) {
        for (var drink in _localDrinks[category]!) {
          final docRef = drinksRef.doc();
          batch.set(docRef, {
            ...drink,
            'category': category,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drinks migrated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  // Delete a drink from Firestore
  Future<void> _deleteDrink(BuildContext context, String drinkId) async {
    try {
      // Confirm deletion with the user
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this drink?'),
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
        // Delete the drink from Firestore
        await _firestore.collection('drinks').doc(drinkId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting drink: $e')),
      );
    }
  }

  // Show dialog to edit a drink
  void _showEditDrinkDialog(
      BuildContext context, String drinkId, Map<String, dynamic> data) {
    final TextEditingController nameController =
        TextEditingController(text: data['name']);
    final TextEditingController imageController =
        TextEditingController(text: data['image']);
    final Map<String, TextEditingController> ingredientControllers = {};
    final TextEditingController preparationController =
        TextEditingController(text: data['preparation']);

    // Initialize ingredient controllers
    (data['ingredients'] as Map<String, dynamic>? ?? {}).forEach((key, value) {
      ingredientControllers[key] =
          TextEditingController(text: value.toString());
    });

    File? _pickedImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Drink'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _pickedImage = File(pickedFile.path);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_pickedImage != null)
                Image.file(_pickedImage!, height: 100, fit: BoxFit.cover),
              const SizedBox(height: 16),
              const Text('Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...ingredientControllers.entries.map((entry) {
                final key = entry.key;
                final controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Ingredient: $key',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          ingredientControllers.remove(key);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton(
                onPressed: () {
                  setState(() {
                    ingredientControllers['New Ingredient'] =
                        TextEditingController();
                  });
                },
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: preparationController,
                decoration: const InputDecoration(labelText: 'Preparation'),
                maxLines: 3,
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
                // Upload image to ImgBB if a new image is selected
                String? imageUrl = imageController.text;
                if (_pickedImage != null) {
                  imageUrl = await _uploadImageToImgBB(_pickedImage!);
                }

                // Update the drink in Firestore
                await _firestore.collection('drinks').doc(drinkId).update({
                  'name': nameController.text,
                  'image': imageUrl,
                  'ingredients': Map.fromEntries(ingredientControllers.entries
                      .where((entry) => entry.value.text.isNotEmpty)
                      .map((entry) => MapEntry(entry.key, entry.value.text))),
                  'preparation': preparationController.text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating drink: $e')),
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

  // Show dialog to add a new drink
  void _showAddDrinkDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final Map<String, TextEditingController> ingredientControllers = {};
    final TextEditingController preparationController = TextEditingController();

    File? _pickedImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Drink'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _pickedImage = File(pickedFile.path);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_pickedImage != null)
                Image.file(_pickedImage!, height: 100, fit: BoxFit.cover),
              const SizedBox(height: 16),
              const Text('Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...ingredientControllers.entries.map((entry) {
                final key = entry.key;
                final controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Ingredient: $key',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          ingredientControllers.remove(key);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton(
                onPressed: () {
                  setState(() {
                    ingredientControllers['New Ingredient'] =
                        TextEditingController();
                  });
                },
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: preparationController,
                decoration: const InputDecoration(labelText: 'Preparation'),
                maxLines: 3,
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
                // Upload image to ImgBB if a new image is selected
                String? imageUrl;
                if (_pickedImage != null) {
                  imageUrl = await _uploadImageToImgBB(_pickedImage!);
                }

                // Add the drink to Firestore
                await _firestore.collection('drinks').add({
                  'name': nameController.text,
                  'image': imageUrl,
                  'ingredients': Map.fromEntries(ingredientControllers.entries
                      .where((entry) => entry.value.text.isNotEmpty)
                      .map((entry) => MapEntry(entry.key, entry.value.text))),
                  'preparation': preparationController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding drink: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF794022),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Show drink details
  void _showDrinkDetails(BuildContext context, Map<String, dynamic> drink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(drink['name'] ?? 'Drink Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (drink['image'] != null)
                Image.network(drink['image'], height: 150, fit: BoxFit.cover),
              const SizedBox(height: 16),
              const Text('Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...(drink['ingredients'] as Map<String, dynamic>? ?? {})
                  .entries
                  .map((e) {
                return Text('• ${e.key}: ${e.value}');
              }).toList(),
              const SizedBox(height: 16),
              const Text('Preparation:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(drink['preparation'] ?? ''),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drinks'),
        backgroundColor: const Color(0xFF794022),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDrinkDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _migrateDrinks,
            tooltip: 'Migrate Local Drinks',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('drinks').orderBy('category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No drinks found in Firestore'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _migrateDrinks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                    ),
                    child: const Text('Migrate Local Drinks'),
                  ),
                ],
              ),
            );
          }
          // Group drinks by category
          final drinksByCategory = <String, List<DocumentSnapshot>>{};
          for (final doc in snapshot.data!.docs) {
            final category =
                (doc.data() as Map<String, dynamic>)['category'] as String? ??
                    'Uncategorized';
            drinksByCategory.putIfAbsent(category, () => []).add(doc);
          }
          return ListView(
            children: drinksByCategory.entries.map((entry) {
              return ExpansionTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF794022),
                  ),
                ),
                children: entry.value.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF794022).withOpacity(0.1),
                        child: const Icon(Icons.local_drink,
                            color: Color(0xFF794022)),
                      ),
                      title: Text(
                        data['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(data['preparation'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditDrinkDialog(context, doc.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDrink(context, doc.id),
                          ),
                        ],
                      ),
                      onTap: () => _showDrinkDetails(context, data),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AdminDrinksScreen extends StatefulWidget {
  const AdminDrinksScreen({super.key});

  @override
  State<AdminDrinksScreen> createState() => _AdminDrinksScreenState();
}

class _AdminDrinksScreenState extends State<AdminDrinksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String imgbbApiKey = "f53f2b2d663578cc4c7ddba11a81a8dc";

  final List<String> drinkCategories = [
    "Black Coffee",
    "Cold Coffee",
    "Latte",
    "Mocha",
    "Iced Latte",
    "Blended Coffee",
    "Hot Chocolate",
    "Tea",
    "Specialty"
  ];

  String? _selectedCategory;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController prepController = TextEditingController();
  final List<TextEditingController> ingredientControllers = [];
  File? _pickedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = drinkCategories.first;
    ingredientControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    nameController.dispose();
    prepController.dispose();
    for (var controller in ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _checkImageSourceAvailable() async {
    try {
      final ImagePicker picker = ImagePicker();
      return true;
    } catch (e) {
      debugPrint('Error checking image source: $e');
      return false;
    }
  }

  Future<void> _pickImage() async {
    try {
      await _checkImageSourceAvailable();

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          if (!kIsWeb) {
            _pickedImage = File(pickedFile.path);
          } else {
            _pickedImage = null;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Could not access images. Please check app permissions in your device settings.")),
      );
    }
  }

  Future<String?> _uploadImageToImgBB() async {
    if (_pickedImage == null && _imageBytes == null) return null;

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );

      request.fields['key'] = imgbbApiKey;

      if (kIsWeb && _imageBytes != null) {
        final base64Image = base64Encode(_imageBytes!);
        request.fields['image'] = base64Image;
      } else if (!kIsWeb && _pickedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _pickedImage!.path,
          filename: 'drink_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } else if (_imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(_imageBytes!);

        request.files.add(await http.MultipartFile.fromPath(
          'image',
          tempFile.path,
          filename: 'drink_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } else {
        throw Exception('No image data available to upload');
      }

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      final responseString = await streamedResponse.stream.bytesToString();

      debugPrint('ImgBB Response Code: ${streamedResponse.statusCode}');
      debugPrint('ImgBB Response: $responseString');

      if (streamedResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data']['url'];
        } else {
          throw Exception(
              'Image upload returned success=false: ${jsonResponse['error'] ?? "Unknown error"}');
        }
      } else {
        throw Exception(
            'Failed to upload image. Status: ${streamedResponse.statusCode}, Response: $responseString');
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: ${e.toString()}")),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addNewDrink(BuildContext context) {
    nameController.clear();
    prepController.clear();
    for (var controller in ingredientControllers) {
      controller.dispose();
    }
    ingredientControllers.clear();
    ingredientControllers.add(TextEditingController());
    _pickedImage = null;
    _imageBytes = null;
    _selectedCategory = drinkCategories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add New Drink"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: drinkCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateDialog(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Tap to add image"),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Drink Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ingredientControllers.map((controller) {
                    final index = ingredientControllers.indexOf(controller);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Ingredient',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                if (ingredientControllers.length > 1) {
                                  ingredientControllers[index].dispose();
                                  ingredientControllers.removeAt(index);
                                } else {
                                  ingredientControllers[index].clear();
                                }
                              });
                            },
                          )
                        ],
                      ),
                    );
                  }),
                  ElevatedButton.icon(
                    onPressed: () {
                      setStateDialog(() {
                        ingredientControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Ingredient"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: prepController,
                    decoration: const InputDecoration(
                      labelText: 'Preparation',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _saveNewDrink(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text("Add Drink"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveNewDrink(BuildContext context) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drink name is required")),
      );
      return;
    }

    if (prepController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preparation instructions are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedImage != null || _imageBytes != null) {
        imageUrl = await _uploadImageToImgBB();
        if (imageUrl == null) {
          throw Exception("Failed to upload image. Please try again.");
        }
      }

      final ingredients = <String>[];
      for (var controller in ingredientControllers) {
        if (controller.text.trim().isNotEmpty) {
          ingredients.add(controller.text.trim());
        }
      }

      await _firestore.collection('drinks').add({
        'name': nameController.text.trim(),
        'preparation': prepController.text.trim(),
        'ingredients': ingredients,
        'image': imageUrl,
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drink added successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding drink: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editDrink(
      String drinkId, Map<String, dynamic> drinkData) async {
    nameController.text = drinkData['name'] ?? '';
    prepController.text = drinkData['preparation'] ?? '';
    _selectedCategory =
        drinkData['category'] as String? ?? drinkCategories.first;

    for (var controller in ingredientControllers) {
      controller.dispose();
    }
    ingredientControllers.clear();

    // Properly handle ingredients data
    List<String> ingredients = [];
    if (drinkData['ingredients'] != null) {
      if (drinkData['ingredients'] is List) {
        ingredients = List<String>.from(
            drinkData['ingredients'].map((item) => item.toString()));
      } else {
        ingredients = [drinkData['ingredients'].toString()];
      }
    }

    for (var ingredient in ingredients) {
      ingredientControllers.add(TextEditingController(text: ingredient));
    }

    if (ingredientControllers.isEmpty) {
      ingredientControllers.add(TextEditingController());
    }

    _pickedImage = null;
    _imageBytes = null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Drink"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: drinkCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateDialog(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : drinkData['image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        drinkData['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.broken_image,
                                                size: 50),
                                          );
                                        },
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text("Tap to change image"),
                                      ],
                                    ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Drink Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ingredientControllers.map((controller) {
                    final index = ingredientControllers.indexOf(controller);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Ingredient',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                if (ingredientControllers.length > 1) {
                                  ingredientControllers[index].dispose();
                                  ingredientControllers.removeAt(index);
                                } else {
                                  ingredientControllers[index].clear();
                                }
                              });
                            },
                          )
                        ],
                      ),
                    );
                  }),
                  ElevatedButton.icon(
                    onPressed: () {
                      setStateDialog(() {
                        ingredientControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Ingredient"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: prepController,
                    decoration: const InputDecoration(
                      labelText: 'Preparation',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _updateDrink(drinkId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text("Update Drink"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateDrink(String drinkId) async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedImage != null || _imageBytes != null) {
        imageUrl = await _uploadImageToImgBB();
      }

      final ingredients = <String>[];
      for (var controller in ingredientControllers) {
        if (controller.text.trim().isNotEmpty) {
          ingredients.add(controller.text.trim());
        }
      }

      final updateData = {
        'name': nameController.text.trim(),
        'preparation': prepController.text.trim(),
        'ingredients': ingredients,
        'category': _selectedCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        updateData['image'] = imageUrl;
      }

      await _firestore.collection('drinks').doc(drinkId).update(updateData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drink updated successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating drink: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDrink(String drinkId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this drink?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      try {
        await _firestore.collection('drinks').doc(drinkId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Drink deleted")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete drink: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Drinks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _addNewDrink(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('drinks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final drinks = snapshot.data!.docs;

          if (drinks.isEmpty) {
            return const Center(
              child: Text(
                'No drinks added yet. Tap the + button to add a drink.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: drinks.length,
            itemBuilder: (context, index) {
              final drink = drinks[index];
              final data = drink.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image,
                                  color: Colors.red);
                            },
                          ),
                        )
                      : const Icon(Icons.local_drink, color: Color(0xFF794022)),
                  title: Text(data['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['category'] ?? 'No category',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['preparation'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editDrink(drink.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDrink(drink.id),
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
}

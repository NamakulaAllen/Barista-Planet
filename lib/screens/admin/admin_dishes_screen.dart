// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore: unused_import, depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

// Define app theme colors for consistency
const Color primaryColor = Color(0xFF794022); // Brown color
const Color secondaryColor = Colors.white;
const Color accentColor = Color(0xFF8D6E63); // Lighter brown for accents

class AdminDishesScreen extends StatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  State<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends State<AdminDishesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _drinkControllers = [];

  String get imgbbApiKey => "f53f2b2d663578cc4c7ddba11a81a8dc";

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
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            if (!kIsWeb) {
              _selectedImage = File(pickedFile.path);
            } else {
              _selectedImage = null;
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: ${e.toString()}")),
      );
    }
  }

  Future<String?> _uploadImageToImgBB() async {
    if (_selectedImage == null && _imageBytes == null) return null;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );
      request.fields['key'] = imgbbApiKey;

      if (kIsWeb && _imageBytes != null) {
        final base64Image = base64.encode(_imageBytes!);
        request.fields['image'] = base64Image;
      } else if (!kIsWeb && _selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          filename: 'dish_${DateTime.now().millisecondsSinceEpoch}.jpg',
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

  void _showAddDishDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _drinkControllers.clear();
    _drinkControllers.add(TextEditingController());
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });

    bool dialogIsLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: secondaryColor,
            title: const Text("Add New Dish",
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateDialog(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            // ignore: deprecated_member_use
                            Border.all(color: primaryColor.withOpacity(0.5)),
                      ),
                      child: _imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 50,
                                        // ignore: deprecated_member_use
                                        color: primaryColor.withOpacity(0.7)),
                                    const SizedBox(height: 8),
                                    const Text("Tap to add image",
                                        style: TextStyle(color: primaryColor)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Dish Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: primaryColor),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      // ignore: deprecated_member_use
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Compatible Drinks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._drinkControllers.map((controller) {
                          int index = _drinkControllers.indexOf(controller);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'Drink Name',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 2.0),
                                      ),
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      fillColor: secondaryColor,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    setStateDialog(() {
                                      if (_drinkControllers.length > 1) {
                                        controller.dispose();
                                        _drinkControllers.removeAt(index);
                                      } else {
                                        controller.clear();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            setStateDialog(() {
                              _drinkControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add, color: secondaryColor),
                          label: const Text("Add Drink",
                              style: TextStyle(color: secondaryColor)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text("Cancel", style: TextStyle(color: primaryColor)),
              ),
              ElevatedButton(
                onPressed: dialogIsLoading
                    ? null
                    : () async {
                        setStateDialog(() => dialogIsLoading = true);
                        await _addDish();
                        if (mounted && context.mounted) {
                          setStateDialog(() => dialogIsLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                ),
                child: dialogIsLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: secondaryColor),
                      )
                    : const Text("Add Dish",
                        style: TextStyle(color: secondaryColor)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addDish() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    try {
      String? imageUrl;
      if (_selectedImage != null || _imageBytes != null) {
        imageUrl = await _uploadImageToImgBB();
        if (imageUrl == null) {
          throw Exception("Failed to upload image");
        }
      }

      final drinks = _drinkControllers
          .map((c) => c.text.trim())
          .where((d) => d.isNotEmpty)
          .toList();

      await _firestore.collection('dishes').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image': imageUrl,
        'drinks': drinks,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dish added successfully'),
            backgroundColor: primaryColor,
          ),
        );
      }

      // Reset form
      _nameController.clear();
      _descriptionController.clear();
      for (var controller in _drinkControllers) {
        controller.clear();
      }
      _drinkControllers.clear();
      _drinkControllers.add(TextEditingController());

      if (mounted) {
        setState(() {
          _selectedImage = null;
          _imageBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding dish: $e')),
        );
      }
    }
  }

  void _showEditDishDialog(String dishId, Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _drinkControllers.clear();

    // Handle drinks data safely
    final drinks = data['drinks'] as List<dynamic>? ?? [];
    for (var drink in drinks) {
      _drinkControllers.add(TextEditingController(text: drink.toString()));
    }
    if (_drinkControllers.isEmpty) {
      _drinkControllers.add(TextEditingController());
    }

    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });

    bool dialogIsLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: secondaryColor,
            title: const Text("Edit Dish",
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateDialog(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.5)),
                      ),
                      child: _imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : data['image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data['image'],
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: primaryColor,
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) => Icon(
                                            Icons.broken_image,
                                            color: primaryColor),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image,
                                            size: 50,
                                            color:
                                                primaryColor.withOpacity(0.7)),
                                        const SizedBox(height: 8),
                                        const Text("Tap to add image",
                                            style:
                                                TextStyle(color: primaryColor)),
                                      ],
                                    ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Dish Name',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: primaryColor),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Compatible Drinks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._drinkControllers.map((controller) {
                          int index = _drinkControllers.indexOf(controller);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'Drink Name',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 2.0),
                                      ),
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      fillColor: secondaryColor,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    setStateDialog(() {
                                      if (_drinkControllers.length > 1) {
                                        controller.dispose();
                                        _drinkControllers.removeAt(index);
                                      } else {
                                        controller.clear();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            setStateDialog(() {
                              _drinkControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add, color: secondaryColor),
                          label: const Text("Add Drink",
                              style: TextStyle(color: secondaryColor)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text("Cancel", style: TextStyle(color: primaryColor)),
              ),
              ElevatedButton(
                onPressed: dialogIsLoading
                    ? null
                    : () async {
                        setStateDialog(() => dialogIsLoading = true);
                        await _saveEditedDish(dishId);
                        if (mounted && context.mounted) {
                          setStateDialog(() => dialogIsLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                ),
                child: dialogIsLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: secondaryColor),
                      )
                    : const Text("Save Changes",
                        style: TextStyle(color: secondaryColor)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveEditedDish(String dishId) async {
    try {
      String? imageUrl;
      if (_selectedImage != null || _imageBytes != null) {
        imageUrl = await _uploadImageToImgBB();
      }

      final drinks = _drinkControllers
          .map((c) => c.text.trim())
          .where((d) => d.isNotEmpty)
          .toList();

      final updateData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'drinks': drinks,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        updateData['image'] = imageUrl;
      }

      await _firestore.collection('dishes').doc(dishId).update(updateData);

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Dish updated successfully"),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating dish: $e")),
        );
      }
    }
  }

  Future<void> _deleteDish(String dishId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text('Delete Dish', style: TextStyle(color: primaryColor)),
        content: const Text('Are you sure you want to delete this dish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _firestore.collection('dishes').doc(dishId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dish deleted successfully'),
              backgroundColor: primaryColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting dish: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Coffee Dishes',
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: secondaryColor),
            onPressed: _isLoading ? null : _showAddDishDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('dishes')
                    .orderBy('createdAt', descending: true) // Most recent first
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.no_food,
                              size: 64, color: primaryColor.withOpacity(0.7)),
                          const SizedBox(height: 16),
                          Text(
                            'No dishes found.',
                            style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showAddDishDialog,
                            icon: const Icon(Icons.add, color: secondaryColor),
                            label: const Text("Add Your First Dish",
                                style: TextStyle(color: secondaryColor)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final dishDoc = snapshot.data!.docs[index];
                          final data = dishDoc.data() as Map<String, dynamic>;

                          // Safely get description substring
                          String description = data['description'] ?? '';
                          if (description.length > 60) {
                            description = '${description.substring(0, 60)}...';
                          }

                          // Get drinks count for display
                          final drinks = data['drinks'] as List<dynamic>? ?? [];
                          final drinksCount = drinks.length;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: Column(
                              children: [
                                // Main dish info
                                ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: data['image'] != null
                                      ? Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              data['image'],
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                    color: primaryColor,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (ctx, obj, st) =>
                                                  Container(
                                                color: Colors.grey[300],
                                                child: Icon(Icons.broken_image,
                                                    color: primaryColor),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color:
                                                primaryColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.coffee,
                                              size: 40, color: primaryColor),
                                        ),
                                  title: Text(
                                    data['name'] ?? 'Unnamed Dish',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: primaryColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  primaryColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              '$drinksCount ${drinksCount == 1 ? 'drink' : 'drinks'}',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: accentColor),
                                        tooltip: 'Edit dish',
                                        onPressed: _isLoading
                                            ? null
                                            : () => _showEditDishDialog(
                                                dishDoc.id, data),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Delete dish',
                                        onPressed: _isLoading
                                            ? null
                                            : () => _deleteDish(dishDoc.id),
                                      ),
                                    ],
                                  ),
                                ),
                                // Drinks section when expanded
                                if (drinks.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                primaryColor.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.local_drink,
                                                  size: 18,
                                                  color: primaryColor),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Compatible Drinks',
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: drinks.map((drink) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: secondaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                      color: primaryColor
                                                          .withOpacity(0.3)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 2,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  drink.toString(),
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDishDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: secondaryColor),
      ),
    );
  }
}

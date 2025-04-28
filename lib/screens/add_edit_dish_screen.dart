import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditDishScreen extends StatefulWidget {
  final Map<String, dynamic>? dish;

  const AddEditDishScreen({super.key, this.dish});

  @override
  State<AddEditDishScreen> createState() => _AddEditDishScreenState();
}

class _AddEditDishScreenState extends State<AddEditDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.dish != null) {
      _nameController.text = widget.dish!['name'];
      _descriptionController.text = widget.dish!['description'];
      _imagePath = widget.dish!['image'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish == null ? 'Add Dish' : 'Edit Dish'),
        backgroundColor: const Color(0xFF794022),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imagePath != null
                      ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.add_a_photo, size: 40)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Dish Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                ),
                child: Text(widget.dish == null ? 'Add Dish' : 'Update Dish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dish = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': _imagePath,
      };
      Navigator.pop(context, dish);
    }
  }
}

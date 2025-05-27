import 'dart:ui';

import 'package:flutter/material.dart';

class DishDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dish;

  const DishDetailScreen(
      {super.key, required this.dish, required bool isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dish['name'] ?? 'Unknown Dish',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview with tap to zoom
              _buildImagePreview(context),

              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showFullScreenImageWithBlur(context, dish['image']);
                  },
                  child: const Text(
                    "See Full Image",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Dish Name
              Text(
                'Name:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dish['name'] ?? 'Unknown Dish',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'Description:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dish['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Drinks Served
              Text(
                'Drinks Served:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._getDrinkList(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getDrinkList() {
    final drinks = dish['drinks'] as List<dynamic>?;

    if (drinks == null || drinks.isEmpty) {
      return [
        const Text('No drinks served.', style: TextStyle(color: Colors.grey)),
      ];
    }

    return drinks.map((drink) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(
              Icons.coffee,
              color: Color(0xFF794022),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              drink.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImageWithBlur(context, dish['image']);
      },
      child: Hero(
        tag: dish['name'] ?? 'default_dish_image',
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: dish['image'] != null
              ? Image.network(dish['image'], fit: BoxFit.cover)
              : const Center(child: Icon(Icons.fastfood, size: 100)),
        ),
      ),
    );
  }

  void _showFullScreenImageWithBlur(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 👈 Allow tapping outside to dismiss
      barrierLabel: "Dismiss",
      barrierColor:
          Colors.black.withOpacity(0.6), // Semi-transparent background
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          alignment: Alignment.center,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: 'fullscreen_${dish['name']}',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

class DrinkDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> drink;

  const DrinkDetailsScreen({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          drink['name'] ?? 'Unknown Drink',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
              _buildImagePreview(context),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showFullScreenImage(context, drink['image']);
                  },
                  child: const Text(
                    "See Full Image",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                'Name:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                drink['name'] ?? 'Unknown Drink',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Ingredients
              Text(
                'Ingredients:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._getIngredientList(),
              const SizedBox(height: 20),

              // Preparation
              Text(
                'Preparation:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                drink['preparation'] ?? 'No preparation instructions.',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, drink['image']);
      },
      child: Hero(
        tag: drink['name'] ?? 'default_drink_image',
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: drink['image'] != null
              ? Image.network(drink['image'], fit: BoxFit.cover)
              : const Center(child: Icon(Icons.fastfood, size: 100)),
        ),
      ),
    );
  }

  List<Widget> _getIngredientList() {
    // Handle both List and Map cases for backward compatibility
    if (drink['ingredients'] == null) {
      return [
        const Text('No ingredients listed.',
            style: TextStyle(color: Colors.grey)),
      ];
    }

    if (drink['ingredients'] is List) {
      // Handle List case (new format)
      final ingredients = drink['ingredients'] as List;
      return ingredients.map((ingredient) {
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
                ingredient.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList();
    } else if (drink['ingredients'] is Map) {
      // Handle Map case (old format if any)
      final ingredients = drink['ingredients'] as Map;
      return ingredients.entries.map((entry) {
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
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList();
    } else {
      // Handle single string case
      return [
        Padding(
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
                drink['ingredients'].toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        )
      ];
    }
  }

  void _showFullScreenImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
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
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Hero(
                  tag: 'fullscreen_${drink['name']}',
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

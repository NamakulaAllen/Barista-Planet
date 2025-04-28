import 'package:flutter/material.dart';
import 'add_edit_dish_screen.dart';

class DishDetailScreen extends StatefulWidget {
  final Map<String, dynamic> dish;
  final bool isAdmin;

  const DishDetailScreen({
    super.key,
    required this.dish,
    this.isAdmin = false,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  bool _showFullImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dish['name'] ?? 'Unknown Dish',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF794022),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showFullImage) {
              setState(() {
                _showFullImage = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editDish,
            ),
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _showFullImage ? _buildFullImageView() : _buildDetailView(),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullImage = true;
              });
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.asset(
                  widget.dish['image'] ?? 'assets/images/default.jpg',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 100),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Tap to view full image',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dish['name'] ?? 'Unknown Dish',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.dish['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Drinks Served:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: (widget.dish['drinks'] as List<dynamic>? ?? [])
                      .map((drink) {
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
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImageView() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFullImage = false;
        });
      },
      child: Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.asset(
              widget.dish['image'] ?? 'assets/images/default.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.fastfood,
                    size: 100, color: Colors.white);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _editDish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDishScreen(
          dish: widget.dish,
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this dish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Simulate deleting the dish locally
              print("Dish Deleted: ${widget.dish['name']}");
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

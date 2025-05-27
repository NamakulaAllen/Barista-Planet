import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryManagementScreen extends StatelessWidget {
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  CategoryManagementScreen({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'New Category Name'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      categories.add({
                        'name': controller.text,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Category'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drink Categories'),
        backgroundColor: const Color(0xFF794022),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categories.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(context, doc.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, String categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('This will NOT delete associated drinks.'),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('categories')
                  .doc(categoryId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Already handled above
    }
  }
}

// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screen imports for navigation
import 'dishes_screen.dart';
import 'drinks_screen.dart';
// ignore: unused_import
import 'drink_details_screen.dart';
// ignore: unused_import
import 'dish_detail_screen.dart';
import 'curriculum_page.dart';
import 'registration_page.dart';
import 'coffee_quiz_screen.dart';
import 'community_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: prefer_final_fields
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  int _userCount = 0; // To store the number of users

  @override
  void initState() {
    super.initState();
    _fetchUserCount(); // Fetch the number of users when the dashboard loads
  }

  // Fetch the number of users from Firestore
  Future<void> _fetchUserCount() async {
    try {
      setState(() {
        _isLoading = true;
      });
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      setState(() {
        _userCount = querySnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADMIN DASHBOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF794022),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Color(0xFF794022),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard header with statistics
                  _buildDashboardHeader(),
                  SizedBox(height: 24),
                  // Search section
                  _buildSearchSection(),
                  SizedBox(height: 24),
                  // Management buttons grid
                  _sectionTitle('Quick Actions'),
                  _managementButtons(),
                  SizedBox(height: 24),
                  // User registrations section
                  _sectionTitle('User Registrations'),
                  _userRegistrationsSection(),
                ],
              ),
            ),
    );
  }

  // Dashboard header with statistics cards
  Widget _buildDashboardHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF794022),
            Color(0xFF794022),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Admin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statsCard(
                title: 'Users',
                value: '$_userCount', // Display the actual user count
                icon: Icons.people,
              ),
              _statsCard(
                title: 'Items',
                value: '120',
                icon: Icons.restaurant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Statistics card widget
  Widget _statsCard(
      {required String title, required String value, required IconData icon}) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Search section
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Users',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF794022),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name or email',
            prefixIcon: Icon(Icons.search, color: Color(0xFF794022)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF794022)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF794022)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ],
    );
  }

  // Management buttons grid
  Widget _managementButtons() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _adminFeatureButton(
          icon: Icons.restaurant,
          label: 'Manage Dishes',
          color: Colors.orange.shade800,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DishesScreen()),
          ),
        ),
        _adminFeatureButton(
          icon: Icons.local_drink,
          label: 'Manage Drinks',
          color: Colors.blue.shade800,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DrinksScreen()),
          ),
        ),
        _adminFeatureButton(
          icon: Icons.menu_book,
          label: 'Curriculum',
          color: Colors.green.shade800,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CurriculumScreen()),
          ),
        ),
        _adminFeatureButton(
          icon: Icons.people,
          label: 'Community',
          color: Colors.purple.shade800,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityScreen()),
          ),
        ),
        _adminFeatureButton(
          icon: Icons.quiz,
          label: 'Coffee Quiz',
          color: Color(0xFF794022),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoffeeQuizScreen()),
          ),
        ),
        _adminFeatureButton(
          icon: Icons.person_add,
          label: 'Registration',
          color: Color(0xFF794012),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationPage()),
          ),
        ),
      ],
    );
  }

  // Improved admin feature button with animations
  Widget _adminFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section title widget
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF794022),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF794022),
            ),
          ),
        ],
      ),
    );
  }

  // User registrations section with Firebase data
  Widget _userRegistrationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF794022)),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('No users found'),
                  ),
                );
              }
              List<DocumentSnapshot> filteredDocs = snapshot.data!.docs;
              if (_searchQuery.isNotEmpty) {
                filteredDocs = filteredDocs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  String name = data['name'] ?? '';
                  String email = data['email'] ?? '';
                  return name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      email.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();
              }
              return _userList(filteredDocs);
            },
          ),
        ],
      ),
    );
  }

  Widget _userList(List<DocumentSnapshot> documents) {
    return Column(
      children: [
        // Table header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Role',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 50),
            ],
          ),
        ),
        // User list items
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  documents[index].data() as Map<String, dynamic>;
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        data['name'] ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        data['email'] ?? 'No email',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(data['role']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['role'] ?? 'User',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _viewUserDetails(documents[index].id),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper function to get color based on user role
  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red[700]!;
      case 'manager':
        return Colors.orange[700]!;
      case 'editor':
        return Colors.green[700]!;
      default:
        return Colors.blue[700]!;
    }
  }

  // View user details
  void _viewUserDetails(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User not found');
            }
            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name'] ?? 'N/A'}'),
                SizedBox(height: 8),
                Text('Email: ${userData['email'] ?? 'N/A'}'),
                SizedBox(height: 8),
                Text('Role: ${userData['role'] ?? 'N/A'}'),
                SizedBox(height: 8),
                Text(
                  'Created At: ${DateTime.fromMillisecondsSinceEpoch(userData['createdAt']?.millisecondsSinceEpoch ?? 0).toString()}',
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'admin_dishes_screen.dart';
// import 'admin_user_screen.dart';

// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _userCount = 0;
//   int _dishCount = 0;
//   bool _isLoading = true;
//   bool _isAdmin = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _checkAdminStatus();
//   }

//   Future<void> _loadData() async {
//     try {
//       final users = await _firestore.collection('users').get();
//       final dishes = await _firestore.collection('dishes').get();

//       setState(() {
//         _userCount = users.size;
//         _dishCount = dishes.size;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading data: $e')),
//       );
//     }
//   }

//   Future<void> _checkAdminStatus() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       setState(() {
//         _isAdmin = userDoc.data()?['role'] == 'admin';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isAdmin && !_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Access Denied')),
//         body: const Center(
//           child: Text('You must be an admin to access this page'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'ADMIN DASHBOARD',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF794022),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await _auth.signOut();
//               if (!mounted) return;
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF794022),
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildDashboardHeader(),
//                   const SizedBox(height: 24),
//                   _sectionTitle('Management Tools'),
//                   _managementButtons(),
//                   const SizedBox(height: 24),
//                   _sectionTitle('Quick Stats'),
//                   _buildStatsGrid(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildDashboardHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFF794022),
//             Color(0xFF5a3019),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Admin Console',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Manage your restaurant content and users',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 24,
//             decoration: BoxDecoration(
//               color: const Color(0xFF794022),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF794022),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _managementButtons() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.1,
//       mainAxisSpacing: 15,
//       crossAxisSpacing: 15,
//       children: [
//         _adminFeatureButton(
//           icon: Icons.restaurant,
//           label: 'Manage Dishes',
//           color: Colors.orange.shade800,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AdminDishesScreen()),
//           ),
//         ),
//         _adminFeatureButton(
//           icon: Icons.people,
//           label: 'Manage Users',
//           color: Colors.blue.shade800,
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
//           ),
//         ),
//         _adminFeatureButton(
//           icon: Icons.analytics,
//           label: 'Analytics',
//           color: Colors.green.shade800,
//           onTap: () {},
//         ),
//         _adminFeatureButton(
//           icon: Icons.settings,
//           label: 'Settings',
//           color: Colors.purple.shade800,
//           onTap: () {},
//         ),
//       ],
//     );
//   }

//   Widget _adminFeatureButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required Color color,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.7), color],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.5,
//       mainAxisSpacing: 15,
//       crossAxisSpacing: 15,
//       children: [
//         _statCard(
//           title: 'Total Users',
//           value: _userCount.toString(),
//           icon: Icons.people,
//           color: Colors.blue,
//         ),
//         _statCard(
//           title: 'Total Dishes',
//           value: _dishCount.toString(),
//           icon: Icons.restaurant,
//           color: Colors.orange,
//         ),
//         _statCard(
//           title: 'Active Today',
//           value: '24',
//           icon: Icons.today,
//           color: Colors.green,
//         ),
//         _statCard(
//           title: 'Revenue',
//           value: '\$1,245',
//           icon: Icons.attach_money,
//           color: Colors.purple,
//         ),
//       ],
//     );
//   }

//   Widget _statCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 40, color: color),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin _curricullum_screen.dart';
import 'admin_dishes_screen.dart';
import 'admin_drinks_screen.dart';
import 'admin_quiz_management-screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _migrateInitialData(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // Get references to all collections
      final dishesRef = FirebaseFirestore.instance.collection('dishes');
      final drinksRef = FirebaseFirestore.instance.collection('drinks');
      final quizRef = FirebaseFirestore.instance.collection('quiz_questions');
      final curriculumRef = FirebaseFirestore.instance.collection('curriculum');

      // Check if data already exists
      final dishesSnapshot = await dishesRef.get();
      final drinksSnapshot = await drinksRef.get();
      final quizSnapshot = await quizRef.get();
      final curriculumSnapshot = await curriculumRef.get();

      // Implementation of data migration would go here
      // The dishes data has been removed as requested

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Migration process initiated')));
    } catch (e) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Migration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1100;
    final isMediumScreen = MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).size.width <= 1100;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    // Automatically collapse sidebar on small screens
    if (isSmallScreen && _isExpanded) {
      _isExpanded = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: isSmallScreen
          ? AppBar(
              title: const Text(
                'Coffee Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF794022),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  onPressed: () => _migrateInitialData(context),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _handleLogout(context),
                ),
              ],
            )
          : null,
      drawer: isSmallScreen ? _buildDrawer(context) : null,
      body: Row(
        children: [
          // Side Navigation - only show on medium and large screens
          if (!isSmallScreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isExpanded ? 250 : 70,
              child: _buildDrawer(context),
            ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: _buildSelectedScreen(isSmallScreen, isMediumScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return Drawer(
      elevation: 0,
      child: Container(
        color: const Color(0xFF3D2314),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(_isExpanded ? 16.0 : 8.0),
              decoration: const BoxDecoration(
                color: Color(0xFF794022),
              ),
              child: Row(
                mainAxisAlignment: _isExpanded
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (_isExpanded || isSmallScreen)
                    const Text(
                      'Coffee Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!isSmallScreen)
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.menu_open : Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                ],
              ),
            ),
            _buildNavItem(0, Icons.dashboard, 'Dashboard'),
            _buildNavItem(1, Icons.restaurant, 'Dishes'),
            _buildNavItem(2, Icons.local_drink, 'Drinks'),
            _buildNavItem(3, Icons.quiz, 'Quiz'),
            _buildNavItem(4, Icons.menu_book, 'Curriculum'),
            const Spacer(),
            Divider(color: Colors.white24, height: 1),
            _buildNavItem(5, Icons.cloud_upload, 'Migrate Data'),
            _buildNavItem(6, Icons.logout, 'Logout'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    // Always show text on small screens (drawer mode)
    final showText = _isExpanded || isSmallScreen;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: showText ? 16.0 : 0,
        vertical: 2,
      ),
      leading: Container(
        width: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFD2B48C) : Colors.white70,
        ),
      ),
      title: showText
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD2B48C) : Colors.white70,
              ),
            )
          : null,
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      selectedTileColor: Colors.white10,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Close drawer if on small screen
        if (isSmallScreen) {
          Navigator.pop(context);
        }

        // Handle special actions
        if (index == 5) {
          _migrateInitialData(context);
        } else if (index == 6) {
          _handleLogout(context);
        }
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildSelectedScreen(bool isSmallScreen, bool isMediumScreen) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardOverview(isSmallScreen, isMediumScreen);
      case 1:
        return const AdminDishesScreen();
      case 2:
        return const AdminDrinksScreen();
      case 3:
        return const AdminQuizScreen();
      case 4:
        return const AdminCurriculumScreen();
      default:
        return _buildDashboardOverview(isSmallScreen, isMediumScreen);
    }
  }

  Widget _buildDashboardOverview(bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with responsive layout
          _buildResponsiveHeader(isSmallScreen),
          const SizedBox(height: 24),

          // Stats cards with responsive layout
          _buildResponsiveStatsCards(isSmallScreen, isMediumScreen),
          const SizedBox(height: 24),

          // Charts and Recent Activity with responsive layout
          Expanded(
            child:
                _buildResponsiveChartAndActivity(isSmallScreen, isMediumScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2314),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(Icons.access_time, 'Updated: Just now'),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF794022),
                  side: const BorderSide(color: Color(0xFF794022)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2314),
            ),
          ),
          Row(
            children: [
              _buildStatChip(Icons.access_time, 'Last updated: Just now'),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF794022),
                  side: const BorderSide(color: Color(0xFF794022)),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveStatsCards(bool isSmallScreen, bool isMediumScreen) {
    final statCards = [
      _buildStatCard('Total Dishes', '10', Icons.restaurant, Colors.orange),
      const SizedBox(width: 16, height: 16),
      _buildStatCard('Total Drinks', '15', Icons.local_drink, Colors.blue),
      const SizedBox(width: 16, height: 16),
      _buildStatCard('Quiz Questions', '25', Icons.quiz, Colors.green),
      const SizedBox(width: 16, height: 16),
      _buildStatCard('Curriculum Items', '8', Icons.menu_book, Colors.purple),
    ];

    if (isSmallScreen) {
      // Display in a column for small screens
      return Column(
        children: statCards
            .map((widget) => widget is SizedBox
                ? SizedBox(height: widget.height)
                : SizedBox(width: double.infinity, child: widget))
            .toList(),
      );
    } else if (isMediumScreen) {
      // Display as 2x2 grid for medium screens
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: statCards[0]),
              statCards[1],
              Expanded(child: statCards[2]),
            ],
          ),
          statCards[3],
          Row(
            children: [
              Expanded(child: statCards[4]),
              statCards[5],
              Expanded(child: statCards[6]),
            ],
          ),
        ],
      );
    } else {
      // Display in a row for large screens
      return Row(
        children: statCards
            .where((widget) => widget is! SizedBox || widget.width != null)
            .toList(),
      );
    }
  }

  Widget _buildResponsiveChartAndActivity(
      bool isSmallScreen, bool isMediumScreen) {
    // Chart and activity in separate rows for small/medium screens
    if (isSmallScreen || isMediumScreen) {
      return Column(
        children: [
          // Chart section
          Expanded(
            flex: 1,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Usage Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2314),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Distribution of items across collections',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildPieChart(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recent Activity section
          Expanded(
            flex: 1,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D2314),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF794022),
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildActivityList(isSmallScreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Chart and activity side by side for large screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left section - Chart
          Expanded(
            flex: 3,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Usage Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2314),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Distribution of items across collections',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildPieChart(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right section - Recent Activity
          Expanded(
            flex: 2,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D2314),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF794022),
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildActivityList(isSmallScreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildActivityList(bool isSmallScreen) {
    return ListView(
      children: [
        _buildActivityItem(
          'New drink added',
          'Caramel Latte',
          '2 hours ago',
          Icons.add_circle_outline,
          Colors.green,
          isSmallScreen,
        ),
        _buildActivityItem(
          'Quiz question updated',
          'Question #12',
          '3 hours ago',
          Icons.edit,
          Colors.orange,
          isSmallScreen,
        ),
        _buildActivityItem(
          'Dish modified',
          'Espresso Cup',
          '5 hours ago',
          Icons.edit,
          Colors.blue,
          isSmallScreen,
        ),
        _buildActivityItem(
          'Curriculum item deleted',
          'Coffee History',
          'Yesterday',
          Icons.delete_outline,
          Colors.red,
          isSmallScreen,
        ),
        _buildActivityItem(
          'New quiz added',
          'Coffee Basics',
          'Yesterday',
          Icons.add_circle_outline,
          Colors.green,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 60,
                height: isSmallScreen ? 40 : 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 20 : 30,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 12 : 16, color: Colors.grey[600]),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: isSmallScreen ? 40 : 70,
        sections: [
          PieChartSectionData(
            value: 10,
            title: 'Dishes',
            color: Colors.orange,
            radius: isSmallScreen ? 50 : 80,
            titleStyle: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 15,
            title: 'Drinks',
            color: Colors.blue,
            radius: isSmallScreen ? 50 : 80,
            titleStyle: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 25,
            title: 'Quiz',
            color: Colors.green,
            radius: isSmallScreen ? 50 : 80,
            titleStyle: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 8,
            title: 'Curriculum',
            color: Colors.purple,
            radius: isSmallScreen ? 50 : 80,
            titleStyle: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String action,
    String item,
    String time,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

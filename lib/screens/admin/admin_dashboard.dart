import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

// Screens
import 'admin _curricullum_screen.dart';

import 'admin_dishes_screen.dart';
import 'admin_drinks_screen.dart';
import 'admin_quiz_management-screen.dart';
import 'admin_registrations-screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Stats
  int _dishCount = 0;
  int _drinkCount = 0;
  int _quizCount = 0;
  int _curriculumCount = 0;
  int _userCount = 0;
  int _registrationCount = 0;
  bool _isLoading = true;

  late Stream<QuerySnapshot> _registrationStream;

  // Add chart data
  List<FlSpot> _registrationChartData = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _registrationStream = FirebaseFirestore.instance
        .collection('registrations')
        .orderBy('registrationDate', descending: true)
        .snapshots(); // Real-time registration stream
    _fetchRegistrationChartData();
  }

  // Added method to fetch chart data
  Future<void> _fetchRegistrationChartData() async {
    try {
      final lastWeekRegistrations = await FirebaseFirestore.instance
          .collection('registrations')
          .orderBy('registrationDate')
          .get();

      // Process the data for chart
      final Map<String, int> dailyCounts = {};

      for (var doc in lastWeekRegistrations.docs) {
        final data = doc.data();
        final timestamp = data['registrationDate'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateKey = '${date.day}/${date.month}';

          dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
        }
      }

      // Convert to chart data
      List<FlSpot> spots = [];
      int index = 0;
      dailyCounts.forEach((key, value) {
        spots.add(FlSpot(index.toDouble(), value.toDouble()));
        index++;
      });

      setState(() {
        _registrationChartData = spots;
      });
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
    }
  }

  Future<void> _fetchStats() async {
    try {
      final dishesSnap =
          await FirebaseFirestore.instance.collection('dishes').get();
      final drinksSnap =
          await FirebaseFirestore.instance.collection('drinks').get();
      final quizSnap =
          await FirebaseFirestore.instance.collection('quiz_questions').get();
      final curriculumSnap =
          await FirebaseFirestore.instance.collection('curriculum').get();
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      final registrationsSnap =
          await FirebaseFirestore.instance.collection('registrations').get();

      if (mounted) {
        setState(() {
          _dishCount = dishesSnap.size;
          _drinkCount = drinksSnap.size;
          _quizCount = quizSnap.size;
          _curriculumCount = curriculumSnap.size;
          _userCount = usersSnap.size;
          _registrationCount = registrationsSnap.size;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from the admin panel? You will be redirected to the login page.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794022),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout & Go to Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, return early
    if (confirmed != true) {
      return;
    }

    // Show loading indicator while logging out
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF794022)),
          ),
        );
      },
    );

    try {
      // Perform logout
      await FirebaseAuth.instance.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login screen and remove all previous routes
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }

      // Show success message with login link
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Logged out successfully! Redirected to login page.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                // Ensure we're on login page
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message with manual login option
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logout failed: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Go to Login',
              textColor: Colors.white,
              onPressed: () {
                // Force navigate to login even if logout failed
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ),
        );
      }
    }
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
      case 5:
        return const AdminRegistrationsScreen(); // New registration screen
      default:
        return _buildDashboardOverview(isSmallScreen, isMediumScreen);
    }
  }

  // Fixed stat card to not use Expanded when inside a Wrap
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;
    return SizedBox(
      width: isSmallScreen ? double.infinity : 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 60,
                height: isSmallScreen ? 40 : 60,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 20 : 30),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 12 : 14)),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 18 : 24)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveStatsCards(bool isSmallScreen, bool isMediumScreen) {
    // Calculate how many cards per row based on screen size
    final cardsPerRow = isSmallScreen ? 1 : (isMediumScreen ? 2 : 3);
    final cardWidth =
        (MediaQuery.of(context).size.width - (cardsPerRow + 1) * 16) /
            cardsPerRow;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: [
        SizedBox(
          width: cardWidth,
          child: _buildStatCard('Dishes', _isLoading ? '...' : '$_dishCount',
              Icons.restaurant, Colors.orange),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard('Drinks', _isLoading ? '...' : '$_drinkCount',
              Icons.local_drink, Colors.blue),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard('Quiz', _isLoading ? '...' : '$_quizCount',
              Icons.quiz, Colors.green),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
              'Curriculum',
              _isLoading ? '...' : '$_curriculumCount',
              Icons.menu_book,
              Colors.purple),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard('Users', _isLoading ? '...' : '$_userCount',
              Icons.person, Colors.grey),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
              'Registrations',
              _isLoading ? '...' : '$_registrationCount',
              Icons.group,
              Colors.red),
        ),
      ],
    );
  }

  // Added chart widget
  Widget _buildRegistrationChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registration Trends',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _registrationChartData.isEmpty
                  ? const Center(child: Text("No chart data available"))
                  : Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _registrationChartData,
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                // ignore: deprecated_member_use
                                color: Colors.orange.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationList(BuildContext context, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Registrations',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: _registrationStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final registrations = snapshot.data!.docs;
                  if (registrations.isEmpty) {
                    return const Center(child: Text("No registrations yet."));
                  }
                  return ListView.builder(
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final reg =
                          registrations[index].data() as Map<String, dynamic>;
                      final name =
                          "${reg['firstName'] ?? ''} ${reg['lastName'] ?? ''}";
                      final email = reg['email'] ?? 'No email';
                      final phone = reg['phone'] ?? 'No phone';
                      final nationalId = reg['nationalId'] ?? 'No ID';
                      final payment = reg['paymentMethod'] ?? 'Unknown';
                      final timestamp = reg['registrationDate'] as Timestamp?;
                      final formattedDate = _formatTimestamp(timestamp);
                      final totalAmount = reg['totalAmount'] ?? 0;
                      final status = reg['status'] ?? 'Unknown';

                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.orange),
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: $email'),
                            Text('Phone: $phone'),
                            Text('NIN: $nationalId'),
                            Text('Payment: $payment'),
                            Text('Total: UGX $totalAmount'),
                            Text('Status: $status'),
                            Text('Registered: $formattedDate'),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh,
              color: Colors.white), // Fixed: Added white color
          label: const Text('Refresh Data',
              style:
                  TextStyle(color: Colors.white)), // Fixed: Added white color
          onPressed: () {
            setState(() => _isLoading = true);
            _fetchStats();
            _fetchRegistrationChartData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF794022),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardOverview(bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildResponsiveHeader(isSmallScreen),
          const SizedBox(height: 24),
          _buildResponsiveStatsCards(isSmallScreen, isMediumScreen),
          const SizedBox(height: 24),
          _buildRegistrationChart(), // Added chart
          const SizedBox(height: 24),
          _buildRegistrationList(context, isSmallScreen),
        ]),
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
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(color: Color(0xFF794022)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  IconButton(
                    icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu,
                        color: Colors.white),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ],
              ),
            ),
            _buildNavItem(0, Icons.dashboard, 'Dashboard'),
            _buildNavItem(1, Icons.restaurant, 'Dishes'),
            _buildNavItem(2, Icons.local_drink, 'Drinks'),
            _buildNavItem(3, Icons.quiz, 'Quiz'),
            _buildNavItem(4, Icons.menu_book, 'Curriculum'),
            _buildNavItem(5, Icons.group, 'Registrations'), // New nav item
            _buildNavItem(6, Icons.cloud_upload, 'Migrate Data'),
            _buildNavItem(7, Icons.logout, 'Logout'),
            const Spacer(),
            Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;
    final showText = _isExpanded || isSmallScreen;
    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: showText ? 16.0 : 0, vertical: 2),
      leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: Icon(icon,
              color: isSelected ? const Color(0xFFD2B48C) : Colors.white70)),
      title: showText
          ? Text(title,
              style: TextStyle(
                  color: isSelected ? const Color(0xFFD2B48C) : Colors.white70))
          : null,
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedTileColor: Colors.white10,
      onTap: () {
        setState(() => _selectedIndex = index);
        if (isSmallScreen) Navigator.pop(context);
        if (index == 6) {
          _migrateInitialData(context);
        } else if (index == 7) {
          _handleLogout(context);
        }
      },
    );
  }

  // Improved migrate data function
  Future<void> _migrateInitialData(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Data Migration'),
          content: const Text(
              'This will perform initial data migration. Are you sure you want to continue?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // Show progress indicator
    scaffoldMessenger.showSnackBar(
      const SnackBar(
          content: Text('Migration process initiated, please wait...')),
    );

    try {
      // The actual migration logic would go here
      final dishesRef = FirebaseFirestore.instance.collection('dishes');
      final drinksRef = FirebaseFirestore.instance.collection('drinks');
      // ignore: unused_local_variable
      final quizRef = FirebaseFirestore.instance.collection('quiz_questions');
      // ignore: unused_local_variable
      final curriculumRef = FirebaseFirestore.instance.collection('curriculum');

      // Sample initial data
      final sampleDish = {
        'name': 'Sample Coffee Dish',
        'description': 'A delicious coffee dish description',
        'price': 15000,
        'imageUrl': 'https://example.com/sample.jpg',
        'category': 'Specialty',
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final sampleDrink = {
        'name': 'Sample Coffee Drink',
        'description': 'A refreshing coffee drink description',
        'price': 10000,
        'imageUrl': 'https://example.com/sample-drink.jpg',
        'category': 'Hot Drinks',
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Check if collections are empty before adding sample data
      final dishesSnapshot = await dishesRef.limit(1).get();
      if (dishesSnapshot.docs.isEmpty) {
        await dishesRef.add(sampleDish);
      }

      final drinksSnapshot = await drinksRef.limit(1).get();
      if (drinksSnapshot.docs.isEmpty) {
        await drinksRef.add(sampleDrink);
      }

      // Show success message
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Migration completed successfully')),
      );

      // Refresh data
      _fetchStats();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  // Fixed timestamp formatting
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final date = timestamp.toDate();

    // Pad single digit values with leading zeros
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1100;
    final isMediumScreen =
        MediaQuery.of(context).size.width > 600 && !isLargeScreen;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isSmallScreen
          ? AppBar(
              title: const Text('Barista Admin',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF794022),
              iconTheme: const IconThemeData(
                  color: Colors.white), // Fixed: Added white color for icons
              leading: IconButton(
                  icon: const Icon(Icons.menu,
                      color: Colors.white), // Fixed: Added white color
                  onPressed: () => _scaffoldKey.currentState?.openDrawer()),
              actions: [
                IconButton(
                    icon: const Icon(Icons.cloud_upload,
                        color: Colors.white), // Fixed: Added white color
                    onPressed: () => _migrateInitialData(context)),
                IconButton(
                    icon: const Icon(Icons.logout,
                        color: Colors.white), // Fixed: Added white color
                    onPressed: () => _handleLogout(context)),
              ],
            )
          : null,
      drawer: isSmallScreen ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isExpanded ? 250 : 70,
              child: _buildDrawer(context),
            ),
          Expanded(
              child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: _buildSelectedScreen(isSmallScreen, isMediumScreen))),
        ],
      ),
    );
  }
}

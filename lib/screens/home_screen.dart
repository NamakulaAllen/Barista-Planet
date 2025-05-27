import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'community_screen.dart';
import 'my_account_page.dart';
import 'dishes_screen.dart';
import 'drinks_screen.dart';
import 'recents_screen.dart';
import 'curriculum_page.dart';
import 'registration_page.dart';
import 'coffee_quiz_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String fullName = "";
  int selectedIndex = 1;
  final PageController pageController = PageController(viewportFraction: 0.8);
  List<String> recentPages = [];
  int _currentCarouselIndex = 0;

  // List of carousel items for reuse
  final List<CarouselItem> _carouselItems = [
    CarouselItem(imagePath: 'assets/images/trends.jpg', title: 'Coffee Trends'),
    CarouselItem(imagePath: 'assets/images/beans.jpg', title: 'Bean Selection'),
    CarouselItem(imagePath: 'assets/images/news.jpg', title: 'Industry News'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize user name when the screen loads
    _getUserFullName();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _getUserFullName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            fullName = userData['fullName'] ?? "User";
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          fullName = "User";
        });
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void trackRecentPage(String pageName) {
    if (!recentPages.contains(pageName)) {
      setState(() {
        recentPages.insert(0, pageName);
      });
    }
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return RecentsScreen(history: recentPages, recentPages: []);
      case 1:
        return _buildHomeContent(); // Home screen content
      case 2:
        return const MyAccountPage();
      default:
        return Container(); // Fallback
    }
  }

  // Home screen content
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                fullName.isNotEmpty
                    ? '${getGreeting()}, $fullName!'
                    : '${getGreeting()}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      height: 140,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                    items: _carouselItems.map((item) {
                      return buildTrendingCard(
                        imagePath: item.imagePath,
                        title: item.title,
                        onTap: () {},
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Carousel indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _carouselItems.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCarouselIndex == entry.key
                              ? const Color(0xFF794022)
                              : Colors.grey.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      const url = 'https://ugandacoffee.go.ug/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text(
                      'Read More...',
                      style: TextStyle(
                        color: Color(0xFF794022),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildGridButton(
                      label: 'Dishes',
                      icon: Icons.local_cafe,
                      onTap: () {
                        trackRecentPage('Dishes');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DishesScreen(),
                          ),
                        );
                      },
                      width: 166,
                    ),
                    const SizedBox(width: 20),
                    buildGridButton(
                      label: 'Drinks',
                      icon: Icons.local_drink,
                      onTap: () {
                        trackRecentPage('Drinks');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DrinksScreen(),
                          ),
                        );
                      },
                      width: 166,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildGridButton(
                      label: 'Curriculum',
                      icon: Icons.book,
                      onTap: () {
                        trackRecentPage('Curriculum');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CurriculumScreen(),
                          ),
                        );
                      },
                      width: 111,
                    ),
                    const SizedBox(width: 10),
                    buildGridButton(
                      label: 'Community',
                      icon: Icons.people,
                      onTap: () {
                        trackRecentPage('Community');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CommunityScreen(),
                          ),
                        );
                      },
                      width: 111,
                    ),
                    const SizedBox(width: 10),
                    buildGridButton(
                      label: 'Quiz', // Replaced "Airtime & Data"
                      icon: Icons.quiz, // Icon for quizzes
                      onTap: () {
                        trackRecentPage('Coffee Quiz');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CoffeeQuizScreen(), // Navigate to CoffeeQuizScreen
                          ),
                        );
                      },
                      width: 111,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 250,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF794022),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Color(0xFF794022)),
            label: 'My Account',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF794022),
        unselectedItemColor: Colors.grey,
        iconSize: 30,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        onTap: onItemTapped,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF794022),
              ),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/coffee1.jpg'),
                        fit: BoxFit.cover,
                        opacity: 0.5,
                      ),
                    ),
                  ),
                  _buildContent(), // Display content based on selected index
                ],
              ),
            ),
    );
  }

  // Define the buildTrendingCard method
  Widget buildTrendingCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              width: 250,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          // Title overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Define the buildGridButton method
  Widget buildGridButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    double width = 70,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0x1A794022), width: 1),
              ),
              fixedSize: Size(width, 80),
              elevation: 3,
            ),
            child: Column(
              children: [
                Icon(icon, size: 35, color: const Color(0xFF794022)),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF794022),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for carousel items
class CarouselItem {
  final String imagePath;
  final String title;

  CarouselItem({required this.imagePath, required this.title});
}

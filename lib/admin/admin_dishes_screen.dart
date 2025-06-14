// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'dish_detail_screen.dart';
// import 'add_edit_dish_screen.dart';

// class DishesScreen extends StatelessWidget {
//   // Local data as a fallback
//   final List<Map<String, dynamic>> localDishes = [
//     {
//       'name': 'Cappuccino Cup',
//       'image': 'assets/images/cool1.jpg',
//       'description':
//           'A wide-rimmed cup designed to hold frothy cappuccinos, enhancing aroma and flavor.',
//       'drinks': ['Cappuccino', 'Flat White'],
//     },
//     {
//       'name': 'Collins Glass',
//       'image': 'assets/images/cap2.jpg',
//       'description':
//           'A tall, narrow glass ideal for iced coffee or coffee-based cocktails.',
//       'drinks': ['Iced Coffee', 'Coffee Mojito'],
//     },
//     {
//       'name': 'Espresso Cup',
//       'image': 'assets/images/cap3.jpg',
//       'description':
//           'A small, thick-walled cup that preserves heat and enhances the crema of espresso.',
//       'drinks': ['Espresso', 'Macchiato', 'Doppio'],
//     },
//     {
//       'name': 'Coupette Glass',
//       'image': 'assets/images/de.jpg',
//       'description':
//           'A wide, shallow glass perfect for serving espresso martinis or coffee-based cocktails.',
//       'drinks': ['Espresso Martini', 'Irish Coffee'],
//     },
//     {
//       'name': 'Latte Glass',
//       'image': 'assets/images/cap5.jpg',
//       'description':
//           'A tall, heat-resistant glass used for serving layered lattes and specialty coffee drinks.',
//       'drinks': ['Latte', 'Caramel Macchiato'],
//     },
//     {
//       'name': 'Demitasse Cup',
//       'image': 'assets/images/cap6.jpg',
//       'description':
//           'A small cup, usually 2-3 oz, ideal for serving strong coffee like espresso or Turkish coffee.',
//       'drinks': ['Espresso', 'Turkish Coffee', 'Ristretto'],
//     },
//     {
//       'name': 'Irish Coffee Glass',
//       'image': 'assets/images/irish.jpg',
//       'description':
//           'A heat-resistant glass with a handle, designed for serving hot Irish coffee with whiskey and cream.',
//       'drinks': ['Irish Coffee', 'Baileys Coffee'],
//     },
//     {
//       'name': 'Tiki Mug',
//       'image': 'assets/images/cup7.jpg',
//       'description':
//           'A decorative mug used for serving coffee-based cocktails, adding a unique presentation element.',
//       'drinks': ['Coffee Colada', 'Tiki Espresso'],
//     },
//     {
//       'name': 'Cortado Glass',
//       'image': 'assets/images/cup8.jpg',
//       'description':
//           'A small glass designed for cortados, balancing the espresso with an equal amount of steamed milk.',
//       'drinks': ['Cortado', 'Piccolo Latte'],
//     },
//     {
//       'name': 'Double Walled Glass',
//       'image': 'assets/images/cup9.jpg',
//       'description':
//           'An insulated glass that keeps coffee hot while remaining cool to the touch, ideal for modern espresso drinks.',
//       'drinks': ['Espresso', 'Flat White', 'Americano'],
//     },
//   ];

//   DishesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'COFFEE DISHES',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Color(0xFF794022),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: _buildGrid(localDishes),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _addNewDish(context),
//         backgroundColor: Color(0xFF794022),
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildGrid(List<Map<String, dynamic>> dishes) {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: dishes.length,
//       itemBuilder: (context, index) {
//         final dish = dishes[index];
//         return _buildDishCard(context, dish);
//       },
//     );
//   }

//   Widget _buildDishCard(BuildContext context, Map<String, dynamic> dish) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DishDetailScreen(
//               dish: dish,
//               isAdmin: true, // Assuming admin access for simplicity
//             ),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         elevation: 5,
//         child: Column(
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//                 child: Image.asset(
//                   dish['image'] ?? 'assets/images/default.jpg',
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 dish['name'],
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addNewDish(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddEditDishScreen(),
//       ),
//     );
//   }
// }

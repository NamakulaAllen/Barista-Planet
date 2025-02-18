// create a mockup screen using appropriate flutter widgetrs (container,row, column,stack)
// so here is how the scren looks
// on top left,there is a back arrow in a circle, in middle a word Details in top rigt corner a heart icon in a circle
// in the middle of scrren the is a picture , below the picture on the left there is word Ageratum on the right the is a star icon then 4.8(268Reviews)
// below these there are worss which end with ...ReadMore
// below the paragragh sentence are small titles Size, Plant, Height, Humidity. all on one line
// below each ther is word Medium,Orchid,Height,Humidity
// below on left ther is title Price and below price ther is $39.99 on right Add to cart and in box with rounded corners

// import 'package:flutter/material.dart';

// class MockupScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(60),
//         child: Container(
//           padding: EdgeInsets.only(left: 16, right: 16),
//           color: Colors.white,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.grey[200],
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.black),
//                   onPressed: () {},
//                 ),
//               ),
//               Text(
//                 "Details",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               CircleAvatar(
//                 backgroundColor: Colors.grey[200],
//                 child: IconButton(
//                   icon: Icon(Icons.favorite_border, color: Colors.red),
//                   onPressed: () {},
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: double.infinity,
//                 height: 250,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(
//                         'assets/images/plant1.png'), // Replace with your image path
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Ageratum",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.star, color: Colors.green),
//                     SizedBox(width: 4),
//                     Text("4.8 (268 Reviews)", style: TextStyle(fontSize: 14)),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Ageratum is a genus of 40 to 60 tropical and warm temperate flowering annuals and perennials from the family Asteraceae, tribe Eupatorieae.Most species are native to Central America....",
//               style: TextStyle(fontSize: 14),
//               overflow: TextOverflow.ellipsis,
//             ),
//             SizedBox(height: 8),
//             GestureDetector(
//               onTap: () {},
//               child: Text(
//                 "Read More",
//                 style: TextStyle(color: Colors.green),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Size",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold)),
//                     Text("Medium", style: TextStyle(fontSize: 14)),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Plant",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold)),
//                     Text("Orchid", style: TextStyle(fontSize: 14)),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Height",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold)),
//                     Text("12.6''", style: TextStyle(fontSize: 14)),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Humidity",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold)),
//                     Text("82%", style: TextStyle(fontSize: 14)),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Price",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 4),
//                     Text("\$39.99",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors
//                         .green, // Replaced `primary` with `backgroundColor`
//                     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     "Add to Cart",
//                     style: TextStyle(fontSize: 14, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

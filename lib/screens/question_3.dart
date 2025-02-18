import 'package:flutter/material.dart';

class MockupScreen extends StatelessWidget {
  const MockupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor:
                    Colors.grey[200], // Changed to a light grey color
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.black), // Icon color to black
                  onPressed: () {},
                ),
              ),
              const Text(
                "Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                backgroundColor:
                    Colors.grey[200], // Changed to a light grey color
                child: IconButton(
                  icon: const Icon(Icons.favorite_border,
                      color: Colors.red), // Heart icon color to red
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/plant1.png'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ageratum",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.green),
                    SizedBox(width: 4),
                    Text("4.8 (268 Reviews)", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Ageratum is a genus of 40 to 60 tropical and warm temperate flowering annuals and perennials from the family Asteraceae, tribe Eupatorieae. Most species are native to Central America....",
              style: TextStyle(fontSize: 14),
              maxLines: 4, // Limit to 4 lines
              overflow: TextOverflow.ellipsis, // Add ellipsis when overflowing
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Read More",
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 25),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Size",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("Medium", style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plant",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("Orchid", style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Height",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("12.6''", style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Humidity",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("82%", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("\$39.99",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .green, // Replaced `primary` with `backgroundColor`
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

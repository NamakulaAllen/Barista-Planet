import 'package:flutter/material.dart';
import 'category_screen.dart'; // Import CategoryScreen

class DrinksScreen extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> coffeeDrinks = {
    'Black Coffee': [
      {
        'name': 'Espresso',
        'image': 'assets/images/e1.jpg',
        'ingredients': {'Espresso': '1 shot'},
        'preparation':
            'Brew a single shot of espresso using an espresso machine.',
      },
      {
        'name': 'Americano',
        'image': 'assets/images/d1.jpg',
        'ingredients': {'Espresso': '1 shot', 'Hot Water': '6 oz'},
        'preparation': 'Brew a shot of espresso and dilute it with hot water.',
      },
    ],
    'Cold Coffee': [
      {
        'name': 'Iced Coffee',
        'image': 'assets/images/e3.jpg',
        'ingredients': {
          'Coffee': '6 oz',
          'Ice Cubes': 'As needed',
          'Sugar': 'To taste'
        },
        'preparation':
            'Brew hot coffee, cool it down, then add ice cubes and sugar.',
      },
      {
        'name': 'Iced Latte',
        'image': 'assets/images/e4.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Ice Cubes': 'As needed'
        },
        'preparation': 'Brew espresso, pour over ice, and add milk.',
      },
    ],
    'Blended Coffee': [
      {
        'name': 'Mocha Frappuccino',
        'image': 'assets/images/e5.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': '1 cup',
          'Chocolate Syrup': '2 tbsp',
          'Milk': '1/2 cup'
        },
        'preparation':
            'Blend espresso, chocolate syrup, milk, and ice until smooth.',
      },
      {
        'name': 'Caramel Frappuccino',
        'image': 'assets/images/e6.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': '1 cup',
          'Caramel Syrup': '2 tbsp',
          'Milk': '1/2 cup'
        },
        'preparation':
            'Blend espresso, caramel syrup, milk, and ice until smooth.',
      },
    ],
    'Latte': [
      {
        'name': 'Vanilla Latte',
        'image': 'assets/images/e7.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Vanilla Syrup': '1 tbsp'
        },
        'preparation':
            'Brew espresso and mix with steamed milk and vanilla syrup.',
      },
      {
        'name': 'Cinnamon Latte',
        'image': 'assets/images/e8.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Milk': '6 oz',
          'Cinnamon Syrup': '1 tbsp'
        },
        'preparation':
            'Brew espresso and mix with steamed milk and cinnamon syrup.',
      },
    ],
    'Mocha': [
      {
        'name': 'Classic Mocha',
        'image': 'assets/images/d2.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Chocolate Syrup': '2 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, add chocolate syrup, and mix with steamed milk.',
      },
      {
        'name': 'White Mocha',
        'image': 'assets/images/e10.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'White Chocolate Syrup': '2 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, add white chocolate syrup, and mix with steamed milk.',
      },
    ],
    'Iced Latte': [
      {
        'name': 'Iced Vanilla Latte',
        'image': 'assets/images/f1.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': 'As needed',
          'Vanilla Syrup': '1 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, pour over ice, and add vanilla syrup and milk.',
      },
      {
        'name': 'Iced Cinnamon Latte',
        'image': 'assets/images/f2.jpg',
        'ingredients': {
          'Espresso': '1 shot',
          'Ice': 'As needed',
          'Cinnamon Syrup': '1 tbsp',
          'Milk': '6 oz'
        },
        'preparation':
            'Brew espresso, pour over ice, and add cinnamon syrup and milk.',
      },
    ],
    'Specialty Coffee': [
      {
        'name': 'Affogato',
        'image': 'assets/images/f3.jpg',
        'ingredients': {'Espresso': '1 shot', 'Vanilla Ice Cream': '1 scoop'},
        'preparation':
            'Brew espresso and pour it over a scoop of vanilla ice cream.',
      },
      {
        'name': 'Cortado',
        'image': 'assets/images/f4.jpg',
        'ingredients': {'Espresso': '1 shot', 'Steamed Milk': '1 oz'},
        'preparation': 'Brew espresso and add a small amount of steamed milk.',
      },
    ],
    'Decaf Coffee': [
      {
        'name': 'Decaf Espresso',
        'image': 'assets/images/f5.jpg',
        'ingredients': {'Decaf Espresso': '1 shot'},
        'preparation': 'Brew a decaffeinated espresso shot.',
      },
      {
        'name': 'Decaf Latte',
        'image': 'assets/images/f5.jpg',
        'ingredients': {'Decaf Espresso': '1 shot', 'Milk': '6 oz'},
        'preparation': 'Brew decaf espresso and mix with steamed milk.',
      },
    ],
    'Hot Chocolate': [
      {
        'name': 'Classic Hot Chocolate',
        'image': 'assets/images/f6.jpg',
        'ingredients': {'Milk': '1 cup', 'Chocolate Syrup': '2 tbsp'},
        'preparation': 'Heat milk and mix in chocolate syrup.',
      },
      {
        'name': 'White Hot Chocolate',
        'image': 'assets/images/f7.jpg',
        'ingredients': {'Milk': '1 cup', 'White Chocolate Syrup': '2 tbsp'},
        'preparation': 'Heat milk and mix in white chocolate syrup.',
      },
    ],
    'Tea': [
      {
        'name': 'Chai Latte',
        'image': 'assets/images/f8.jpg',
        'ingredients': {
          'Black Tea': '1 bag',
          'Milk': '6 oz',
          'Chai Syrup': '1 tbsp'
        },
        'preparation':
            'Brew black tea and mix with steamed milk and chai syrup.',
      },
      {
        'name': 'Green Tea Latte',
        'image': 'assets/images/f9.jpg',
        'ingredients': {
          'Green Tea': '1 bag',
          'Milk': '6 oz',
          'Honey': '1 tbsp'
        },
        'preparation': 'Brew green tea and mix with steamed milk and honey.',
      },
    ],
  };

  DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COFFEE DRINKS',
          style: TextStyle(
            color: Colors.white, // title color
          ),
        ),
        backgroundColor: Color(0xFF794022),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: coffeeDrinks.keys.length,
        itemBuilder: (context, categoryIndex) {
          String category = coffeeDrinks.keys.elementAt(categoryIndex);
          List<Map<String, dynamic>> drinks = coffeeDrinks[category]!;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                      category: category,
                      drinks: drinks,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF794022)),
                      ),
                      Row(
                        children: [
                          Text(
                            '${drinks.length} Drinks',
                            style: TextStyle(
                              color: Color(0xFF794022).withOpacity(0.6),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF794022).withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

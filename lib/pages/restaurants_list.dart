import 'package:test3/components/navigation_bar.dart' as custom_nav_bar;
import 'package:flutter/material.dart';
import 'package:test3/components/restaurant_card.dart';

import 'nearby__restaurants_view.dart';


class RestaurantsListPage extends StatelessWidget {
  const RestaurantsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        leading: IconButton(
          icon: const Icon(Icons.location_on_outlined),
          onPressed: () {
            // Navegar a la vista Nearby Restaurants
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NearbyRestaurantsView()),
            );
          },
        ),
        title: const Text(
          'GASTROANDES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Image.asset(
            'assets/images/logo.png',
          ),
        ],
      ),
      bottomNavigationBar: custom_nav_bar.NavigationBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RestaurantCard(
              imageUrl: 'https://cdn.colombia.com/gastronomia/2011/08/02/bandeja-paisa-1616.webp',
              name: 'Restaurante Doña Juana',
              price: 30000,
              rating: 3,
              reviewCount: 20,
              onTap: () {
                print('hola');
              },
            ),
            RestaurantCard(
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5c9ad911c2ff6119695036bc/1555618361122-RRRJT11LLQUYV8NREX4S/rock+n+roll.jpeg?format=1500w',
              name: 'Bandeja',
              price: 30000,
              rating: 3,
              reviewCount: 20,
              onTap: () {
                print('hola');
              },
            ),
            RestaurantCard(
              imageUrl: 'https://images.squarespace-cdn.com/content/v1/5c9ad911c2ff6119695036bc/1555618361122-RRRJT11LLQUYV8NREX4S/rock+n+roll.jpeg?format=1500w',
              name: 'Bandeja',
              price: 30000,
              rating: 3,
              reviewCount: 20,
              onTap: () {
                print('hola');
              },
            ),
          ],
        ),
      ),
    );
  }
}

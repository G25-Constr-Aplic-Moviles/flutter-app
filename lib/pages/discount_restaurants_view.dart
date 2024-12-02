import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/discounts_viewmodel.dart';  // ViewModel de descuentos
import '../components/restaurant_card.dart';  // Usamos la tarjeta ya existente
import 'restaurant_page.dart';  // Para navegar a detalles de un restaurante

class DiscountRestaurantsPage extends StatefulWidget {
  final String discountType; // Tipo de descuento: 'discount_50off' o 'discount_20off'

  const DiscountRestaurantsPage({super.key, required this.discountType});

  @override
  _DiscountRestaurantsPageState createState() =>
      _DiscountRestaurantsPageState();
}

class _DiscountRestaurantsPageState extends State<DiscountRestaurantsPage> {
  @override
  void initState() {
    super.initState();
    // Llamamos al método de ViewModel para cargar los restaurantes con descuento
    Provider.of<DiscountRestaurantsViewModel>(context, listen: false)
        .fetchRestaurantsWithDiscount(widget.discountType);
  }

  @override
  Widget build(BuildContext context) {
    final discountRestaurantsViewModel =
    Provider.of<DiscountRestaurantsViewModel>(context);
    final restaurants = discountRestaurantsViewModel.restaurantsWithDiscount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        title: Text(
          widget.discountType == 'discount_50off' ? '50% Off Restaurants' : '20% Off Restaurants',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: restaurants.isEmpty
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              imageUrl: restaurant.imageUrl,
              name: restaurant.name,
              averageRating: restaurant.averageRating,
              reviewCount: restaurant.totalReviews,
              address: restaurant.address,
              restaurantType: restaurant.cuisineType,
              onTap: () {
                // Navegar a la página de detalles del restaurante
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantPage(restaurant: restaurant),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/discounts_viewmodel.dart';
import '../components/restaurant_card.dart';

class DiscountedRestaurantsPage extends StatefulWidget {
  final String initialDiscountType;

  const DiscountedRestaurantsPage({required this.initialDiscountType, super.key});

  @override
  _DiscountedRestaurantsPageState createState() =>
      _DiscountedRestaurantsPageState();
}

class _DiscountedRestaurantsPageState extends State<DiscountedRestaurantsPage> {
  late String _currentDiscountType;

  @override
  void initState() {
    super.initState();
    _currentDiscountType = widget.initialDiscountType; // Inicializamos el estado con el descuento recibido.
    _fetchRestaurants();
  }

  void _fetchRestaurants() {
    final viewModel = context.read<DiscountedRestaurantsViewModel>();
    viewModel.fetchRestaurants(_currentDiscountType);
  }

  void _updateDiscountType(String discountType) {
    setState(() {
      _currentDiscountType = discountType;
      _fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discounted Restaurants'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateDiscountType,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'discount_50off',
                child: Text('50% Off'),
              ),
              const PopupMenuItem(
                value: 'discount_20off',
                child: Text('20% Off'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DiscountedRestaurantsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage.isNotEmpty) {
            // Mostrar mensaje de error si no hay conexión ni caché
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage, textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () {
                      _fetchRestaurants();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.restaurants.isEmpty) {
            return const Center(child: Text('No restaurants found.'));
          }

          return ListView.builder(
            itemCount: viewModel.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = viewModel.restaurants[index];
              return RestaurantCard(
                imageUrl: restaurant.imageUrl,
                name: restaurant.name,
                averageRating: restaurant.averageRating,
                reviewCount: restaurant.totalReviews,
                address: restaurant.address,
                restaurantType: restaurant.cuisineType,
                onTap: () {
                  // Manejar la acción del tap
                  print('Tapped on ${restaurant.name}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
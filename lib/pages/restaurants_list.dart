import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/token_manager.dart';
import '../viewmodels/restaurants_list_viewmodel.dart';
import '../viewmodels/route_view_model.dart';
import '../components/navigation_bar.dart' as custom_nav_bar;
import '../components/restaurant_card.dart';
import 'discount_restaurants_view.dart';
import 'dishes_list_view.dart';
import 'nearby__restaurants_view.dart';
import 'restaurant_page.dart';

class RestaurantsListPage extends StatefulWidget {
  const RestaurantsListPage({super.key});

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentCuisineFilter = '';

  @override
  void initState() {
    super.initState();
    final restaurantsViewModel = Provider.of<RestaurantsListViewModel>(context, listen: false);
    restaurantsViewModel.fetchRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDiscountView(String discountType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountedRestaurantsPage(initialDiscountType: discountType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsViewModel = Provider.of<RestaurantsListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        leading: IconButton(
          icon: const Icon(Icons.location_on_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NearbyRestaurantsView()),
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
      bottomNavigationBar: const custom_nav_bar.NavigationBar(),
      body: Column(
        children: [
          // Botones de descuento
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDiscountButton('50% OFF', Colors.red, 'discount_50off'),
                _buildDiscountButton('20% OFF', Colors.orange, 'discount_20off'),
              ],
            ),
          ),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search restaurants...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          _showFilterSheet(restaurantsViewModel);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      restaurantsViewModel.filterRestaurants(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!restaurantsViewModel.isConnected){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Revisa tu conexión a internet'),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      
                      final userId = await TokenManager().userId;
                      if (userId != null) {
                        restaurantsViewModel.fetchRecommendedRestaurants(userId);
                      } else {
                        print("User ID not found. Make sure the user is authenticated");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Icon(
                      Icons.star_border_outlined,
                      color: Color.fromRGBO(255, 82, 71, 1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FoodListView()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color.fromRGBO(255, 82, 71, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentCuisineFilter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total restaurants: ${restaurantsViewModel.filteredRestaurants.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          if (!restaurantsViewModel.isConnected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No internet connection!',
                style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Consumer<RestaurantsListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage.isNotEmpty && viewModel.restaurants.isEmpty) {
                  return Center(
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                if (viewModel.restaurants.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: viewModel.filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = viewModel.filteredRestaurants[index];
                    return RestaurantCard(
                      imageUrl: restaurant.imageUrl,
                      name: restaurant.name,
                      averageRating: restaurant.averageRating,
                      reviewCount: restaurant.totalReviews,
                      address: restaurant.address,
                      restaurantType: restaurant.cuisineType,
                      onTap: () {
                        if (restaurantsViewModel.isConnected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RestaurantPage(restaurant: restaurant)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This feature requires internet connection!',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.black,
                            ),

                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountButton(String text, Color color, String discountType) {
    return GestureDetector(
      onTap: () => _navigateToDiscountView(discountType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(RestaurantsListViewModel viewModel) {
    final cuisineTypes = viewModel.getCuisineTypes().toList();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                setState(() {
                  _currentCuisineFilter = '';
                });
                viewModel.filterRestaurantsByCuisine('');
                Navigator.pop(context);
              },
            ),
            ...cuisineTypes.map((cuisineType) => ListTile(
              title: Text(cuisineType),
              onTap: () {
                setState(() {
                  _currentCuisineFilter = cuisineType;
                });
                viewModel.filterRestaurantsByCuisine(cuisineType);
                Navigator.pop(context);
              },
            )),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantList(RestaurantsListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          viewModel.errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (viewModel.restaurants.isEmpty) {
      return const Center(child: Text('No restaurants available.'));
    }

    return ListView.builder(
      itemCount: viewModel.filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = viewModel.filteredRestaurants[index];
        return RestaurantCard(
          imageUrl: restaurant.imageUrl,
          name: restaurant.name,
          averageRating: restaurant.averageRating,
          reviewCount: restaurant.totalReviews,
          address: restaurant.address,
          restaurantType: restaurant.cuisineType,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RestaurantPage(restaurant: restaurant)),
            );
          },
        );
      },
    );
  }
}

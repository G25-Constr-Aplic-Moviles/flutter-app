import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/token_manager.dart';
import '../viewmodels/restaurants_list_viewmodel.dart';
import '../viewmodels/route_view_model.dart';
import '../components/navigation_bar.dart' as custom_nav_bar;
import '../components/restaurant_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final restaurantsViewModel = Provider.of<RestaurantsListViewModel>(context);
    final routeViewModel = Provider.of<RouteViewModel>(context, listen: false);

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
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              final cuisineTypes = restaurantsViewModel.getCuisineTypes().toList();
                              return ListView(
                                children: [
                                  ListTile(
                                    title: const Text('All'),
                                    onTap: () {
                                      setState(() {
                                        _currentCuisineFilter = '';
                                      });
                                      restaurantsViewModel.filterRestaurantsByCuisine('');
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ...cuisineTypes.map((cuisineType) => ListTile(
                                    title: Text(cuisineType),
                                    onTap: () {
                                      setState(() {
                                        _currentCuisineFilter = cuisineType;
                                      });
                                      restaurantsViewModel.filterRestaurantsByCuisine(cuisineType);
                                      Navigator.pop(context);
                                    },
                                  )).toList(),
                                ],
                              );
                            },
                          );
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
                        MaterialPageRoute(builder: (context) => FoodListView()), // Redirige a la página de la lista de platos
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
          Expanded(
            child: Consumer<RestaurantsListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage.isNotEmpty) {
                  if(viewModel.errorMessage == 'No internet connection!'){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.red, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          viewModel.errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RestaurantPage(restaurant: restaurant)),
                        );
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
}

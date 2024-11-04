import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/models/token_manager.dart';
import '../viewmodels/restaurants_list_viewmodel.dart';
import '../viewmodels/route_view_model.dart';
import '../components/navigation_bar.dart' as custom_nav_bar;
import '../components/restaurant_card.dart';
import 'nearby__restaurants_view.dart';
import 'restaurant_page.dart';

class RestaurantsListPage extends StatefulWidget {
  const RestaurantsListPage({super.key});

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  final TextEditingController _searchController = TextEditingController();

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
                      hintText: 'Buscar restaurantes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // TODO: Filtros
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
                      if(userId != null){
                        restaurantsViewModel.fetchRecommendedRestaurants(userId);
                      } else {
                        print("User ID no encontrado. Asegurate que el usuario este autenticado");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )
                    ),
                    child: const Icon(
                      Icons.star_border_outlined,
                      color: Color.fromRGBO(255, 82, 71, 1)
                      ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<RestaurantsListViewModel>(
              builder: (context, viewModel, child) {
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/restaurants_list_viewmodel.dart';
import '../viewmodels/route_view_model.dart';
import '../components/navigation_bar.dart' as custom_nav_bar;
import '../components/restaurant_card.dart';
import 'route_view.dart';
import 'nearby__restaurants_view.dart';

class RestaurantsListPage extends StatelessWidget {
  const RestaurantsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantsViewModel = Provider.of<RestaurantsListViewModel>(context, listen: false);
    final routeViewModel = Provider.of<RouteViewModel>(context, listen: false);

    restaurantsViewModel.fetchRestaurants();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        leading: IconButton(
          icon: const Icon(Icons.location_on_outlined),
          onPressed: () {
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
      body: Consumer<RestaurantsListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.restaurants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: viewModel.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = viewModel.restaurants[index];
              return RestaurantCard(
                imageUrl: restaurant.imageUrl,
                name: restaurant.name,
                onTap: () {
                  // Establecer el restaurante seleccionado y navegar a la vista de ruta
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteView(restaurant: restaurant),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

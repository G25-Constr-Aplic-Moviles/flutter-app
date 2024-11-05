import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/restaurant_model.dart';
import 'package:test3/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;
import 'package:provider/provider.dart';
import 'package:test3/viewmodels/MenuItemViewModel.dart';
import 'package:test3/viewmodels/restaurant_page_view_model.dart';
import 'package:test3/pages/route_view.dart'; // Importamos la vista de la ruta

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantPage({super.key, required this.restaurant});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late RestaurantPageViewModel _restaurantPageViewModel;

  @override
  void initState() {
    super.initState();
    final menuItemViewModel = Provider.of<MenuItemViewModel>(context, listen: false);
    _restaurantPageViewModel = Provider.of<RestaurantPageViewModel>(context, listen: false);
    menuItemViewModel.fetchMenu(widget.restaurant.id);
  }

  final reviewPreview = Review(
      title: "Increíble",
      username: "MarioLaserna777",
      numberStars: 5.0,
      fullReview:
      "Probé el arroz de lomo y me gustó demasiado, la atención es muy buena. Fue rápido y no es muy caro. Lo recomiendo particularmente si tienen prisa. Fui a las 2 de la tarde y no había mucha gente en el lugar. Ponen música agradable y se disfruta mucho el almuerzo.");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navegar de vuelta
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.network(widget.restaurant.imageUrl),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  _restaurantPageViewModel.markRestaurantVisited(widget.restaurant.id, context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  "Marcar visita",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 10),
              // Botón "Ver Ruta" para redirigir a la vista de ruta
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteView(restaurant: widget.restaurant),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  "Ver Ruta al Restaurante",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Menu",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Implementación para ver el menú completo
                      },
                      child: const Text(
                        "Menu completo",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 5, 82, 215),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 250,
                child: Consumer<MenuItemViewModel>(
                  builder: (context, viewModel, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.foodMenu.length,
                      itemBuilder: (context, index) => FoodBooklet(
                        food: viewModel.foodMenu[index],
                      ),
                    );
                  },
                ),
              ),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      "Reseñas (4.5)",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Text(
                    "Ver todas",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
                  border: Border.all(
                    color: Colors.black, // Color del borde
                    width: 2.0, // Grosor del borde
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            reviewPreview.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            reviewPreview.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: RatingBarIndicator(
                            rating: reviewPreview.numberStars,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.black,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                            direction: Axis.horizontal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              reviewPreview.fullReview,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.justify,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const customNavBar.NavigationBar(),
    );
  }
}

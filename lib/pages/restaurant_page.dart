import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/restaurant_model.dart';
import 'package:test3/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;
import 'package:provider/provider.dart';
import 'package:test3/pages/dish_page.dart';
import 'package:test3/viewmodels/MenuItemViewModel.dart';
import 'package:test3/viewmodels/restaurant_page_view_model.dart';
import 'package:test3/pages/route_view.dart';

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

    _startListeningToConnectivity();
  }

  bool _isProcessingConnectivity = false;

  void _startListeningToConnectivity() {
    final Connectivity _connectivity = Connectivity();

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none && !_isProcessingConnectivity) {
        print("se detecto conexion");
        _isProcessingConnectivity = true;
        await _restaurantPageViewModel.retryPendingVisits(context);
        _isProcessingConnectivity = false;
      }
    });
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
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del restaurante con bordes redondeados
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(widget.restaurant.imageUrl),
              ),
              const SizedBox(height: 20),
              
              // Título del restaurante
              Center(
                child: Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              
              // Botones "Marcar visita" y "Ver ruta al restaurante" en la misma fila
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _restaurantPageViewModel.markRestaurantVisited(widget.restaurant.id, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: const Text(
                        "Marcar visita",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouteView(restaurant: widget.restaurant),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    child: const Text(
                      "Ver Ruta al Restaurante",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Línea delimitadora de la sección de botones
              const Divider(
                color: Colors.black,
                thickness: 1,
                height: 30,
              ),
              
              // Título "Menú"
              const Text(
                "Menú",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),

              // Carrusel horizontal para el menú con margen y línea delimitadora
              SizedBox(
                height: 250,
                child: Consumer<MenuItemViewModel>(
                  builder: (context, viewModel, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.foodMenu.length,
                      itemBuilder: (context, index) {
                        final food = viewModel.foodMenu[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DishPage(food: food),
                              ),
                            );
                          },
                          child: FoodBooklet(food: food),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              
              // Línea delimitadora de la sección de menú
              const Divider(
                color: Colors.black,
                thickness: 1,
                height: 30,
              ),
              
              // Título "Reseñas"
              const Text(
                "Reseñas (4.5)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),

              // Contenedor con sombra para reseñas
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y nombre del usuario de la reseña
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            reviewPreview.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            reviewPreview.username,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Estrellas de valoración
                      RatingBarIndicator(
                        rating: reviewPreview.numberStars,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 10),

                      // Texto de la reseña
                      Text(
                        reviewPreview.fullReview,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
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

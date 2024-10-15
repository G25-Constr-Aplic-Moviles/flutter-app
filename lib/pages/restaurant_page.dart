import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/food.dart';
import 'package:test3/models/restaurant_model.dart';
import 'package:test3/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;
import 'package:test3/pages/full_menu_page.dart';
import 'package:test3/viewmodels/MenuItemViewModel.dart';
import 'package:test3/viewmodels/restaurants_list_viewmodel.dart';
import 'package:provider/provider.dart';

class RestaurantPage extends StatefulWidget {
   final Restaurant restaurant;

   const RestaurantPage({super.key, required this.restaurant});

   @override
   State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>{

  @override
  void initState() {
    super.initState();
    final menuItemViewModel = Provider.of<MenuItemViewModel>(context, listen: false);
    menuItemViewModel.fetchMenu(widget.restaurant.id);
  }

  // reseña que se muestra principalmente
  final reviewPreview = Review(title: "Increible", username: "MarioLaserna777", numberStars: 5.0, 
    fullReview: "Probe el arroz de lomo y me gusto demasiado, la atencion es muy buena. Fue rapido y no es muy caro. Lo recomiendo particularmente si tienen prisa, fui a las 2 de la tarde y  no habia mucha gente en el lugar. Ponen musica agradable y se disfruta mucho el almuerzo.");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        //title: Text(''),
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
              Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30, 
                  ),
              ),
          
              Row(
                children: [
                  Expanded(
                    child: Text(
                                "Menu",
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30, 
                                ),
                              ),
                  ),
                  
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => FullMenuPage()),
                          );
                      },
                      child: Text(
                                  "Menu completo",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30, 
                                    color: Color.fromARGB(255, 5, 82, 215)
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
                        food: viewModel.foodMenu[index]
                      ),  
                    );
                  },
                ),
              ),
        
              Row(
                children: [
                  Expanded(
                    child: Text(
                              "Reseñas (4.5)",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30, 
                              ),
                            ),
                    ),
                  
                  
                  Text(
                              "Ver todas",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
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
                    width: 2.0,         // Grosor del borde
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: Text(
                            reviewPreview.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20, 
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right:8.0),
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
                          padding: const EdgeInsets.only(left:8.0),
                          child: RatingBarIndicator(
                            rating: reviewPreview.numberStars,
                            itemBuilder: (context, index) => Icon(
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
                          child: 
                          Padding(
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
        
              const SizedBox(height: 25),
        
              Row(
                children: [
                  Text(
                      "Ubicación",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
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
                    width: 2.0,         // Grosor del borde
                  ),
                ),
                child: Image.asset('assets/images/yamato_sushi_location.png'),
              ),
            ],
          ),),
      ),
      bottomNavigationBar: customNavBar.NavigationBar(),
    );
  }
}


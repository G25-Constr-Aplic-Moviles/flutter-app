import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/food.dart';

class RestaurantPage extends StatefulWidget {
   const RestaurantPage({super.key});

   @override
   State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>{

  // menu de comidas
   List foodMenu = [
    // Sushi rock n roll
    Food(image: "assets/images/sushi_rock_n_roll.png", price: "19.000", name: "Sushi rock n roll"),

    // Arroz de lomo
    Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/yamato_sushi.png'),
            const SizedBox(height: 25),
            Text(
              "YAMATO SUSHI",
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
                  child: Text(
                              "Menu completo",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30, 
                              ),
                            ),
                ),  
              ],
            ),

            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodMenu.length,
                itemBuilder: (context, index) => FoodBooklet(
                  food: foodMenu[index]
                ),
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

          ],
        ),),
    );
  }
}


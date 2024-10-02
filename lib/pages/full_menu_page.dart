import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/food.dart';

class FullMenuPage extends StatefulWidget {
  const FullMenuPage({super.key});

  @override
  State<FullMenuPage> createState() => _FullMenuPage();
}

class _FullMenuPage extends State<FullMenuPage> {

    // menu de comidas
   List foodMenu = [
    Food(image: "assets/images/sushi_rock_n_roll.png", price: "19.000", name: "Sushi rock n roll"),
    Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo"),
    Food(image: "assets/images/sushi_rock_n_roll.png", price: "19.000", name: "Sushi rock n roll"),
    Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo"),
    Food(image: "assets/images/sushi_rock_n_roll.png", price: "19.000", name: "Sushi rock n roll"),
    Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo"),
    Food(image: "assets/images/sushi_rock_n_roll.png", price: "19.000", name: "Sushi rock n roll"),
    Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo"),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
          Padding(
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
                    Text(
                          "Menu",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30, 
                          ),
                        ),
                  ],
                ),

                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      ), 
                    itemCount: foodMenu.length,
                    itemBuilder: (context, index){
                      return FoodBooklet(food: foodMenu[index]);
                    }
                  ),
                ),
              ],
            ), 
          ),
    );
  }
}
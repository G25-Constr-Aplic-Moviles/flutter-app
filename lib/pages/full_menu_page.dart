import 'package:flutter/material.dart';
import 'package:test3/components/food_booklet.dart';
import 'package:test3/models/food.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;

class FullMenuPage extends StatefulWidget {
  const FullMenuPage({super.key});

  @override
  State<FullMenuPage> createState() => _FullMenuPage();
}

class _FullMenuPage extends State<FullMenuPage> {

    // menu de comidas
   List foodMenu = [
    Food(id: 1, imageUrl: "assets/images/sushi_rock_n_roll.png", price: 19, name: "Sushi rock n roll", description: "hola"),
    Food(id: 2, imageUrl: "assets/images/arroz_lomo.png", price: 20, name: "Arroz de lomo", description: "chao"),
    Food(id: 3, imageUrl: "assets/images/sushi_rock_n_roll.png", price: 19, name: "Sushi rock n roll", description: "hola"),
    Food(id: 4, imageUrl: "assets/images/arroz_lomo.png", price: 20, name: "Arroz de lomo", description: "chao"),
    Food(id: 5, imageUrl: "assets/images/sushi_rock_n_roll.png", price: 19, name: "Sushi rock n roll", description: "hola"),
    Food(id: 6, imageUrl: "assets/images/arroz_lomo.png", price: 20, name: "Arroz de lomo", description: "chao"),
    
  ];
  
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
          bottomNavigationBar: customNavBar.NavigationBar(),
    );
  }
}

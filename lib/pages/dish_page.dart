import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';


class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {

  final food = Food(image: "assets/images/arroz_lomo.png", price: "21.000", name: "Arroz de lomo");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: 
                  Image.asset(
                    food.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover
                  ),
              ),
            ),
            Text(
              food.name,
              style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30, 
              ),
            ),

            Text(
              '\$' + food.price,
              style: const TextStyle(
                    fontSize: 30, 
              ),
            ),

            Text(
              'Un plato clásico elevado a nuevas alturas. Arroz jazmín perfectamente cocido, impregnado con un caldo de carne rico y sabroso, acompañado de jugosos trozos de lomo de res salteados al punto perfecto. Se combina con pimientos asados, cebolla caramelizada y un toque de ajo para un sabor profundo y envolvente.',
              style: const TextStyle(
                fontSize: 25
              ),
            ),
          ],
        ),
      ),
    );
  }
}
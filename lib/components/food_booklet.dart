import "package:flutter/material.dart";
import "package:test3/models/food.dart";

class FoodBooklet extends StatelessWidget {
  final Food food;
  const FoodBooklet({
    super.key,
    required this.food,
    });
  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            height: 100,
            child: Image.network(
              food.imageUrl,
              fit: BoxFit.cover,
              )
          ),

          Text(
            food.name,
            style: const TextStyle(
              fontSize: 20
            ),
          ),

          Text(
            '\$${food.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20
            ),
          ),

      ],
     ),
    );
  }
}
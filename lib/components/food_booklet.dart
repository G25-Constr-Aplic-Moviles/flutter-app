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
      margin: EdgeInsets.only(left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(food.image),

          Text(
            food.name,
            style: const TextStyle(
              fontSize: 20
            ),
          ),

          Text(
            '\$'+ food.price,
            style: const TextStyle(
              fontSize: 20
            ),
          ),

      ],
     ),
    );
  }
}
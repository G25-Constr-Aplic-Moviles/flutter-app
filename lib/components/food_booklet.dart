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
    return Card(
      elevation: 5, // Profundidad de la sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordes redondeados
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0), // Espaciado interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
          mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
          children: [
            // Imagen centrada
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                food.imageUrl,
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10), // Espacio entre la imagen y el texto

            // Nombre del alimento
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5), // Espacio entre el nombre y el precio

            // Precio
            Text(
              '\$${food.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
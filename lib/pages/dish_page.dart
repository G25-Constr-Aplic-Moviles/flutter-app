import 'package:flutter/material.dart';
import 'package:test3/models/experience.dart';
import 'package:test3/models/food.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;


class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage>{ 
  
  final food = Food(id: 2, imageUrl: "assets/images/arroz_lomo.png", price: 20, name: "Arroz de lomo", description: "chao");
  final experience = Experience(experience: "El Arroz de Lomo fue una delicia total. Cada bocado estaba lleno de sabor, con el lomo tierno y jugoso que se deshacía en la boca. La mezcla de pimientos y cebolla le da un toque dulce y ahumado que equilibra perfectamente con el arroz esponjoso. Además, la salsa de soya y jengibre es el complemento ideal, agregando una capa extra de sabor que lo hace irresistible. Sin duda, este plato se ha convertido en uno de mis favoritos. ¡Altamente recomendado!");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        //title: Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: 
                  Image.asset(
                    food.imageUrl,
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
              '\$${food.price}',
              style: const TextStyle(
                    fontSize: 30, 
              ),
            ),

            const Text(
              'Un plato clásico elevado a nuevas alturas. Arroz jazmín perfectamente cocido, impregnado con un caldo de carne rico y sabroso, acompañado de jugosos trozos de lomo de res salteados al punto perfecto. Se combina con pimientos asados, cebolla caramelizada y un toque de ajo para un sabor profundo y envolvente.',
              style: TextStyle(
                fontSize: 20,
                height: 1.2,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  'Experiencias',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                  ),
                ),

                FloatingActionButton.small(
                  backgroundColor: Colors.redAccent,
                  tooltip: 'Increment',
                  onPressed: (){},
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                      experience.experience,
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
      ),
    bottomNavigationBar: const customNavBar.NavigationBar(),
    );
  }
}
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/models/food.dart';
import 'package:test3/components/navigation_bar.dart' as customNavBar;
import 'package:test3/viewmodels/MenuItemViewModel.dart';


class DishPage extends StatefulWidget {
  final Food food;
  DishPage({super.key, required this.food});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage>{ 


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MenuItemViewModel viewModel = Provider.of<MenuItemViewModel>(context, listen: false);
      viewModel.fetchLikesDislikes(widget.food.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    final food = widget.food;
    final viewModel = Provider.of<MenuItemViewModel>(context);
    
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
                  Image.network(
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

            Text(
              food.description,
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
              ],
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Esquinas redondeadas
                border: Border.all(
                  color: Colors.black.withOpacity(0.2), // Border color suavizado
                  width: 2.0,                          // Grosor del borde
                ),
                boxShadow: [                            // Sombra suave para un efecto de elevación
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 2), // Desplazamiento de la sombra
                  ),
                ],
                gradient: LinearGradient(               // Fondo con un gradiente suave
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0), // Más padding para que el contenido no esté tan pegado
              child: Row( // Usamos Row para alinear los elementos horizontalmente
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre los elementos
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botón de like
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      viewModel.updateLikes(widget.food.id);
                    },
                  ),

                  // Columna con el texto
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centrado verticalmente
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if(viewModel.isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        Text(
                          '${viewModel.likesDislikes}%',  // Muestra el porcentaje
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: _getTextColor(viewModel.likesDislikes), // Color dinámico
                          ),
                        ),
                        const SizedBox(height: 8), // Espacio entre el porcentaje y la etiqueta
                        Text(
                          "Recomiendan este plato",  // Etiqueta opcional
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Botón de dislike
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      viewModel.updateDislikes(widget.food.id);
                    },
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    bottomNavigationBar: const customNavBar.NavigationBar(),
    );
  }

Color _getTextColor(int likesDislikes) {
  if (likesDislikes >= 0 && likesDislikes <= 19) {
    return Colors.red;
  } else if (likesDislikes >= 20 && likesDislikes <= 39) {
    return Colors.orange;
  } else if (likesDislikes >= 40 && likesDislikes <= 59) {
    return Colors.yellow;
  } else if (likesDislikes >= 60 && likesDislikes <= 79) {
    return Colors.green;
  } else if (likesDislikes >= 80 && likesDislikes <= 100) {
    return Colors.blue;
  } else {
    return Colors.black; // En caso de que el valor esté fuera de este rango, puedes asignar un color por defecto
  }
}

}
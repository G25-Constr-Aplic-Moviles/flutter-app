import 'package:flutter/material.dart';
import 'views/login.view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginView(),
    );
  }
}

class ArrozDeLomoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/arroz_lomo.jpg', // Replace with your image asset path or use Image.network for network image
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Arroz de lomo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '\$21.000',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(
              'Un plato clásico elevado a nuevas alturas. Arroz jazmín perfectamente cocido, impregnado con un caldo de carne rico y sabroso, acompañado de jugosos trozos de lomo de res salteados al punto perfecto. Se combina con pimientos asados, cebolla caramelizada y un toque de ajo para un sabor profundo y envolvente.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Experiencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'El Arroz de Lomo fue una delicia total. Cada bocado estaba lleno de sabor, con el lomo tierno y jugoso que se deshacía en la boca. La mezcla de pimientos y cebolla le da un toque dulce y ahumado que equilibra perfectamente con el arroz esponjoso. Además, la salsa de soya y jengibre es el complemento ideal, agregando una capa extra de sabor que lo hace irresistible. Sin duda, este plato se ha convertido en uno de mis favoritos; ¡Altamente recomendado!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                iconSize: 40,
                onPressed: () {
                  // Handle button press
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

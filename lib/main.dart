import 'package:flutter/material.dart';
import 'add_experience_view.dart';
import 'add_review_view.dart';
import 'map_view.dart';
import 'history_view.dart';
import 'shortest_route_view.dart'; // Importar la vista de la ruta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Finder',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placeholder Test Main Screen'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla del mapa
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Ver Restaurantes Cercanos'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla para agregar una experiencia
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExperienceScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Agregar Experiencia'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla para agregar una reseña
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddReviewScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Agregar Reseña'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla del historial
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Ver Historial'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de la ruta más corta
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RouteView()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Ver Ruta Más Corta'),
            ),
          ],
        ),
      ),
    );
  }
}

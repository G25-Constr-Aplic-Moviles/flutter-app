import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import '../viewmodels/nearby_restaurants_viewmodel.dart';
import '../models/token_manager.dart';
import 'restaurants_list.dart';

class NearbyRestaurantsView extends StatefulWidget {
  const NearbyRestaurantsView({super.key});

  @override
  _NearbyRestaurantsViewState createState() => _NearbyRestaurantsViewState();
}

class _NearbyRestaurantsViewState extends State<NearbyRestaurantsView> {
  late GoogleMapController mapController;
  late DateTime _startTime;
  final String? _analitycsURL= dotenv.env['API_KEY_HEROKU'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final viewModel = Provider.of<NearbyRestaurantsViewModel>(context, listen: false);

    viewModel.getCurrentLocation().then((_) async {
      if (viewModel.currentLocation != null) {
        await viewModel.fetchNearbyRestaurants();
        if (viewModel.restaurants.isEmpty) {
          await viewModel.loadMarkersFromLocalCache();
          if (viewModel.restaurants.isEmpty) {
            _showConnectionErrorAndRedirect();
          }
        } else {
          _sendAnalytics();
        }
      } else {
        await viewModel.loadMarkersFromLocalCache();
        if (viewModel.restaurants.isEmpty) {
          _showConnectionErrorAndRedirect();
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Captura el snapshot al cargar el mapa si es necesario para uso offline
    _cacheMapSnapshot(controller);
  }

  // Verifica la conectividad antes de intentar tomar el snapshot
  Future<void> _cacheMapSnapshot(GoogleMapController controller) async {
    // Verifica si el widget está montado
    if (!mounted || controller == null) {
      return;
    }

    // Verifica la conectividad a internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      // Solo toma el snapshot si hay conexión a Internet
      try {
        final imageBytes = await controller.takeSnapshot();
        if (imageBytes != null) {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/map_snapshot.png');
          await file.writeAsBytes(imageBytes);
          print("Map snapshot saved successfully.");
        }
      } catch (e) {
        print("Error taking snapshot: $e");
      }
    } else {
      print("No internet connection, not taking snapshot.");
    }
  }

  Future<void> _sendAnalytics() async {
    DateTime endTime = DateTime.now();
    double loadTime = endTime.difference(_startTime).inMilliseconds / 1000;
    String? userId = await TokenManager().userId;

    if (userId == null) {
      print("Error: User ID not found");
      return;
    }

    String? herokuApiUrl = '$_analitycsURL/add_time';
    Map<String, dynamic> data = {
      "plataforma": "Flutter",
      "tiempo": loadTime,
      "timestamp": endTime.toUtc().toIso8601String(),
      "userID": userId,
    };

    try {
      final response = await http.post(
        Uri.parse(herokuApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Metrics sent successfully.");
      } else {
        print("Error sending metrics: ${response.body}");
      }
    } catch (e) {
      print("Error connecting to Heroku service: $e");
    }
  }

  void _showConnectionErrorAndRedirect() {
    // Mostrar mensaje de error y redirigir
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error de Conexión"),
          content: Text("No hay conexión a internet. Saliendo a la página principal."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
                );
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        title: const Text(
          'Nearby Restaurants',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<NearbyRestaurantsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.restaurants.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(viewModel.currentLocation?.latitude ?? 0.0, viewModel.currentLocation?.longitude ?? 0.0),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: viewModel.restaurants
                .map(
                  (restaurant) => Marker(
                markerId: MarkerId(restaurant.id.toString()),
                position: LatLng(restaurant.latitude, restaurant.longitude),
                infoWindow: InfoWindow(title: restaurant.name, snippet: restaurant.address),
              ),
            )
                .toSet(),
          );
        },
      ),
    );
  }
}
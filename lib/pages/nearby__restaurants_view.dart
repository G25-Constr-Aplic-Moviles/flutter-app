import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import '../viewmodels/nearby_restaurants_viewmodel.dart';

class NearbyRestaurantsView extends StatefulWidget {
  @override
  _NearbyRestaurantsViewState createState() => _NearbyRestaurantsViewState();
}

class _NearbyRestaurantsViewState extends State<NearbyRestaurantsView> {
  late GoogleMapController mapController;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Capturamos el tiempo de inicio

    // Obtener la ubicación y los restaurantes desde el ViewModel al iniciar
    final viewModel = Provider.of<NearbyRestaurantsViewModel>(context, listen: false);
    viewModel.getCurrentLocation();
    viewModel.fetchNearbyRestaurants().then((_) {
      _sendAnalytics(); // Enviar las métricas una vez que se carguen los restaurantes
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _sendAnalytics() async {
    // Capturar el tiempo que tomó cargar la vista
    DateTime _endTime = DateTime.now();
    double loadTime = _endTime.difference(_startTime).inMilliseconds / 1000;

    // Obtener la URL del servicio desde el archivo .env
    String herokuApiUrl = dotenv.env['API_KEY_HEROKU'] ?? '';

    // Datos a enviar
    Map<String, dynamic> data = {
      "plataforma": Platform.operatingSystem, // "Android", "iOS", "Windows", etc.
      "tiempo": loadTime,
      "timestamp": _endTime.toUtc().toIso8601String(),
      "userID": "example_user_id_123", // Deberías obtener el ID real del usuario aquí
    };

    // Enviar los datos al servicio de Heroku
    try {
      final response = await http.post(
        Uri.parse(herokuApiUrl), // Usar la variable del archivo .env
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Métricas enviadas correctamente.");
      } else {
        print("Error al enviar métricas: ${response.body}");
      }
    } catch (e) {
      print("Error al conectar con el servicio de Heroku: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NearbyRestaurantsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Set<Marker> markers = {};
          for (var restaurant in viewModel.restaurants) {
            markers.add(
              Marker(
                markerId: MarkerId(restaurant.name),
                position: LatLng(restaurant.latitude, restaurant.longitude),
                infoWindow: InfoWindow(title: restaurant.name),
              ),
            );
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(viewModel.currentLocation!.latitude!, viewModel.currentLocation!.longitude!),
              zoom: 15.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../viewmodels/route_view_model.dart';
import '../models/restaurant_model.dart';
import '../models/token_manager.dart';
import 'restaurant_page.dart'; // Importa la página de detalle del restaurante

class RouteView extends StatefulWidget {
  final Restaurant restaurant;

  const RouteView({required this.restaurant, super.key});

  @override
  _RouteViewState createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  late GoogleMapController mapController;
  late DateTime _startTime;
  bool _isLoading = true; // Estado para mostrar la carga inicial
  final String? _analyticsURL = dotenv.env['API_KEY_HEROKU'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Captura el tiempo de inicio

    final viewModel = Provider.of<RouteViewModel>(context, listen: false);

    // Obtención de ubicación y ruta
    viewModel.getCurrentLocation().then((_) async {
      try {
        await viewModel.fetchRouteToRestaurant(widget.restaurant);
        setState(() {
          _isLoading = false; // Finaliza la carga si la ruta es exitosa
        });
        _sendAnalytics();
      } catch (e) {
        // Intentar cargar desde caché si falla la API
        final isCached = await viewModel.loadRouteFromCache(widget.restaurant.id);
        if (!isCached) {
          _showConnectionErrorAndRedirect(); // Mostrar pop-up y redirigir
        } else {
          setState(() {
            _isLoading = false; // Finaliza la carga si se encuentran datos en caché
          });
        }
      }
    }).catchError((_) {
      _showConnectionErrorAndRedirect(); // Error al obtener ubicación
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _sendAnalytics() async {
    DateTime endTime = DateTime.now();
    double loadTime = endTime.difference(_startTime).inMilliseconds / 1000; // Tiempo de carga en segundos
    String? userId = await TokenManager().userId;

    if (userId == null) {
      print("Error: User ID not found");
      return;
    }

    String? herokuApiUrl = '$_analyticsURL/add_time';
    Map<String, dynamic> data = {
      "plataforma": "Flutter",
      "tiempo": loadTime,
      "timestamp": endTime.toUtc().toIso8601String(),
      "userID": userId,
      "feature": "route_view_load_time" // Identificador para esta métrica
    };

    try {
      final response = await http.post(
        Uri.parse(herokuApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Metrics sent successfully for RouteView.");
      } else {
        print("Error sending metrics: ${response.body}");
      }
    } catch (e) {
      print("Error connecting to Heroku service: $e");
    }
  }

  void _showConnectionErrorAndRedirect() {
    // Mostrar pop-up y redirigir al detalle del restaurante
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error de Conexión"),
          content: const Text("No se pudo cargar la ruta. Revisa tu conexión a internet e inténtalo de nuevo."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RestaurantPage(restaurant: widget.restaurant),
                  ),
                ); // Redirige al detalle del restaurante
              },
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
        title: Text('Ruta a ${widget.restaurant.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga
          : Consumer<RouteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.route == null) {
            return const Center(
              child: Text("Sorry! We could not load the route,please check your internet connection and try again"),
            );
          }

          // Marcadores para el usuario y el restaurante
          Set<Marker> markers = {
            if (viewModel.currentLocation != null)
              Marker(
                markerId: const MarkerId('userLocation'),
                position: LatLng(
                  viewModel.currentLocation!.latitude!,
                  viewModel.currentLocation!.longitude!,
                ),
                infoWindow: const InfoWindow(title: 'Mi Ubicación'),
              ),
            Marker(
              markerId: MarkerId(widget.restaurant.name),
              position: LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
              infoWindow: InfoWindow(title: widget.restaurant.name),
            ),
          };

          // Líneas de la ruta
          Set<Polyline> polylines = {};
          if (viewModel.route != null) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: viewModel.route!.points,
              ),
            );
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
              zoom: 15.0,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}
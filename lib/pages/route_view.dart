import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../viewmodels/route_view_model.dart';
import '../models/restaurant_model.dart';
import '../models/token_manager.dart';

class RouteView extends StatefulWidget {
  final Restaurant restaurant;

  const RouteView({required this.restaurant, super.key});

  @override
  _RouteViewState createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  late GoogleMapController mapController;
  late DateTime _startTime;
  final String? _analyticsURL = dotenv.env['API_KEY_HEROKU'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Captura el tiempo de inicio

    final viewModel = Provider.of<RouteViewModel>(context, listen: false);
    viewModel.getCurrentLocation().then((_) {
      viewModel.fetchRouteToRestaurant(widget.restaurant).then((_) {
        _sendAnalytics(); // Enviar métricas cuando la ruta esté lista
      }).catchError((error) {
        // Manejar conectividad eventual: Cargar la ruta en caché si hay error
        viewModel.loadRouteFromCache(widget.restaurant.id).then((isCached) {
          if (isCached) {
            _showCachedRouteNotification(context);
          } else {
            _showConnectionErrorNotification(context);
          }
        });
      });
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

  void _showCachedRouteNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mostrando una ruta en caché debido a problemas de conexión"),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showConnectionErrorNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error de conexión: No se pudo cargar la ruta"),
        duration: Duration(seconds: 3),
      ),
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
      body: Consumer<RouteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Set<Marker> markers = {
            Marker(
              markerId: const MarkerId('userLocation'),
              position: LatLng(viewModel.currentLocation!.latitude!, viewModel.currentLocation!.longitude!),
              infoWindow: const InfoWindow(title: 'Mi Ubicación'),
            ),
            Marker(
              markerId: MarkerId(widget.restaurant.name),
              position: LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
              infoWindow: InfoWindow(title: widget.restaurant.name),
            ),
          };

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
              target: LatLng(viewModel.currentLocation!.latitude!, viewModel.currentLocation!.longitude!),
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

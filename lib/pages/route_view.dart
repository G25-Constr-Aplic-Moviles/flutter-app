import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/route_view_model.dart';
import '../models/restaurant_model.dart';
import 'restaurant_page.dart';

class RouteView extends StatefulWidget {
  final Restaurant restaurant;

  const RouteView({required this.restaurant, super.key});

  @override
  _RouteViewState createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    final viewModel = Provider.of<RouteViewModel>(context, listen: false);

    // Intentar obtener la ruta
    viewModel.getCurrentLocation().then((_) async {
      try {
        await viewModel.fetchRouteToRestaurant(widget.restaurant);
      } catch (e) {
        _showConnectionErrorAndRedirect();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Mostrar mensaje de error y redirigir al usuario
  void _showConnectionErrorAndRedirect() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error de conexión"),
          content: const Text("No se pudo obtener la ruta. Revisa tu conexión a Internet."),
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
      body: Consumer<RouteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.route == null) {
            return const Center(child: Text("Cargando ruta..."));
          }

          // Dibujar marcadores y la ruta en el mapa
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

          Set<Polyline> polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: viewModel.route!.points,
            ),
          };

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

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/route_view_model.dart';
import '../models/restaurant_model.dart';

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
    viewModel.getCurrentLocation().then((_) {
      viewModel.fetchRouteToRestaurant(widget.restaurant);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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

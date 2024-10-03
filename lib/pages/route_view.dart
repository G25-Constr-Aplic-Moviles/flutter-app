import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '/../viewmodels/route_view_model.dart';
import '/../models/restaurant_model.dart';

class RouteView extends StatefulWidget {
  final Restaurant restaurant;

  RouteView({required this.restaurant});

  @override
  _RouteViewState createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // Obtener la ubicación y la ruta hacia el restaurante desde el ViewModel al iniciar
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
        title: Text('Route to ${widget.restaurant.name}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<RouteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return Center(child: CircularProgressIndicator());
          }

          Set<Marker> markers = {
            Marker(
              markerId: MarkerId('userLocation'),
              position: LatLng(viewModel.currentLocation!.latitude!, viewModel.currentLocation!.longitude!),
              infoWindow: InfoWindow(title: 'My Location'),
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
                polylineId: PolylineId('route'),
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

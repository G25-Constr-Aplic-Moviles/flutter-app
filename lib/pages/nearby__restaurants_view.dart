import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../viewmodels/nearby_restaurants_viewmodel.dart';

class NearbyRestaurantsView extends StatefulWidget {
  @override
  _NearbyRestaurantsViewState createState() => _NearbyRestaurantsViewState();
}

class _NearbyRestaurantsViewState extends State<NearbyRestaurantsView> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // Obtener la ubicación y los restaurantes desde el ViewModel al iniciar
    final viewModel = Provider.of<NearbyRestaurantsViewModel>(context, listen: false);
    viewModel.getCurrentLocation();
    viewModel.fetchNearbyRestaurants();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Restaurants'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NearbyRestaurantsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.currentLocation == null) {
            return Center(child: CircularProgressIndicator());
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

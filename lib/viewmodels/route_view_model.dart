import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/../models/route_model.dart';
import '/../models/restaurant_model.dart';
import '/../services/api_service.dart';

class RouteViewModel extends ChangeNotifier {
  LocationData? _currentLocation;
  RouteModel? _route;
  Location location = Location();
  final ApiService _apiService = ApiService();

  LocationData? get currentLocation => _currentLocation;
  RouteModel? get route => _route;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _currentLocation = await location.getLocation();
    notifyListeners();
  }

  Future<void> fetchRouteToRestaurant(Restaurant restaurant) async {
    if (_currentLocation == null) return;

    try {
      final String apiKey = 'YOUR_GOOGLE_API_KEY';
      Map<String, dynamic> data = await _apiService.fetchRoute(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        restaurant.latitude,
        restaurant.longitude,
        apiKey,
      );

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        String polylinePoints = data['routes'][0]['overview_polyline']['points'];
        _route = RouteModel.fromEncodedPolyline(polylinePoints);
        notifyListeners();
      } else {
        print('No route found');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }
}

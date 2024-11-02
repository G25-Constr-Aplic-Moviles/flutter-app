import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class NearbyRestaurantsViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  LocationData? _currentLocation;
  Location location = Location();
  final ApiService _apiService = ApiService();

  List<Restaurant> get restaurants => _restaurants;
  LocationData? get currentLocation => _currentLocation;

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

  Future<void> fetchNearbyRestaurants() async {
    try {
      if (_currentLocation == null) return; // Ensure location is available

      List<dynamic> data = await _apiService.fetchRestaurants();
      List<Restaurant> allRestaurants = data.map((item) => Restaurant.fromJson(item)).toList();

      _restaurants = allRestaurants.where((restaurant) {
        double distance = _calculateDistance(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          restaurant.latitude,
          restaurant.longitude,
        );

        // Filter restaurants within 1 km range
        return distance <= 1.0;
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radiusOfEarth = 6371; // Radius of Earth in km
    double dLat = _degreeToRadian(lat2 - lat1);
    double dLon = _degreeToRadian(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) * cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}

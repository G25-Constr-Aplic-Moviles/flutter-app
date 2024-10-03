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
      List<dynamic> data = await _apiService.fetchRestaurants();
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }
}
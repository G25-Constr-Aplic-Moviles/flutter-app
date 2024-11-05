import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importación de LatLng
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../models/route_model.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

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
      const String apiKey = 'YOUR_API_KEY_HERE';
      Map data = await _apiService.fetchRoute(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        restaurant.latitude,
        restaurant.longitude,
        apiKey,
      );

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        String polylinePoints = data['routes'][0]['overview_polyline']['points'];
        _route = RouteModel.fromEncodedPolyline(polylinePoints);

        // Guardar la ruta en caché
        await _saveRouteToCache(restaurant.id, _route!);

        notifyListeners();
      } else {
        print('No route found');
      }
    } catch (e) {
      print('Error fetching route: $e');
      // Intentar cargar desde la caché si hay un error de conexión
      await loadRouteFromCache(restaurant.id);
    }
  }

  Future<void> _saveRouteToCache(int restaurantId, RouteModel route) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/route_$restaurantId.json');

    Map<String, dynamic> routeData = {
      'points': route.points.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList(),
    };

    await file.writeAsString(jsonEncode(routeData));
    print("Route saved to cache for restaurant ID: $restaurantId");
  }

  Future<bool> loadRouteFromCache(int restaurantId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/route_$restaurantId.json');

    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonData = jsonDecode(contents);

      List<LatLng> points = (jsonData['points'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList();

      _route = RouteModel(points: points);
      notifyListeners();
      print("Route loaded from cache for restaurant ID: $restaurantId");
      return true;
    } else {
      print("No cached route found for restaurant ID: $restaurantId");
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import '../sqlite/database_helper.dart';


class RestaurantsListViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  final ApiService _apiService = ApiService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;

  RestaurantsListViewModel() {
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    try {
      // Verificar el estado de la conexión
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      // Intentar obtener datos de la red con un timeout de 4 segundos
      final response = await _apiService.fetchRestaurants().timeout(Duration(seconds: 4));
      List<dynamic> data = response;
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();

      // Guardar los datos en la base de datos
      await _databaseHelper.deleteAllRestaurants();
      for (var restaurant in _restaurants) {
        await _databaseHelper.insertRestaurant(restaurant);
      }
    } catch (e) {
      print('Error fetching restaurants from network: $e');
      // Si falla, obtener datos de la base de datos
      _restaurants = await _databaseHelper.getRestaurants();
      if (_restaurants.isEmpty) {
        print('No cached data available');
      }
    }
    _filteredRestaurants = _restaurants;
    notifyListeners();
  }

  Future<void> fetchRecommendedRestaurants(String userId) async {
    try {
      // Verificar el estado de la conexión
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      // Intentar obtener datos de la red con un timeout de 4 segundos
      final response = await _apiService.fetchRecommendedRestaurants(userId).timeout(Duration(seconds: 4));
      List<dynamic> data = response;
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();

      // Guardar los datos en la base de datos
      await _databaseHelper.deleteAllRestaurants();
      for (var restaurant in _restaurants) {
        await _databaseHelper.insertRestaurant(restaurant);
      }
    } catch (e) {
      print('Error fetching recommended restaurants from network: $e');
      // Si falla, obtener datos de la base de datos
      _restaurants = await _databaseHelper.getRestaurants();
      if (_restaurants.isEmpty) {
        print('No cached data available');
      }
    }
    _filteredRestaurants = _restaurants;
    notifyListeners();
  }

  void filterRestaurants(String query) {
    if (query.isEmpty) {
      _filteredRestaurants = _restaurants;
    } else {
      _filteredRestaurants = _restaurants
          .where((restaurant) => restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

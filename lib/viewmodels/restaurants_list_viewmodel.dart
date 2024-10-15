import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class RestaurantsListViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  final ApiService _apiService = ApiService();

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants=> _filteredRestaurants;

  Future<void> fetchRestaurants() async {
    try {
      List<dynamic> data = await _apiService.fetchRestaurants();
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      _filteredRestaurants= _restaurants;
      notifyListeners();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
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

import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class RestaurantsListViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  final ApiService _apiService = ApiService();

  List<Restaurant> get restaurants => _restaurants;

  Future<void> fetchRestaurants() async {
    try {
      List<dynamic> data = await _apiService.fetchRestaurants();
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }
}

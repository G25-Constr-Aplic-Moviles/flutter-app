import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  Future<void> fetchRecommendedRestaurants(String userId) async {
    try{
      List<dynamic> data = await _apiService.fetchRecommendedRestaurants(userId);
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      _filteredRestaurants = _restaurants;
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

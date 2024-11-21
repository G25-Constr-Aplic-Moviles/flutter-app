import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class RestaurantsListViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  final ApiService _apiService = ApiService();
  bool _isConnected = true;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  RestaurantsListViewModel() {
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        fetchRestaurants();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<void> fetchRestaurants() async {
    await _checkConnectivity();
    if (!_isConnected) {
      _errorMessage = 'No internet connection!';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<dynamic> data = await _apiService.fetchRestaurants().timeout(Duration(seconds: 4));
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      _filteredRestaurants = _restaurants;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'No internet connection!';
      _isConnected = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendedRestaurants(String userId) async {
    await _checkConnectivity();
    if (!_isConnected) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<dynamic> data = await _apiService.fetchRecommendedRestaurants(userId).timeout(Duration(seconds: 4));
      _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      _filteredRestaurants = _restaurants;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'No internet connection!';
      _isConnected = false;
    } finally {
      _isLoading = false;
      notifyListeners();
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

  void filterRestaurantsByCuisine(String cuisineType) {
    if (cuisineType.isEmpty) {
      _filteredRestaurants = _restaurants;
    } else {
      _filteredRestaurants = _restaurants
          .where((restaurant) => restaurant.cuisineType.toLowerCase() == cuisineType.toLowerCase())
          .toList();
    }
    notifyListeners();
  }

  Set<String> getCuisineTypes() {
    return _restaurants.map((restaurant) => restaurant.cuisineType).toSet();
  }
}

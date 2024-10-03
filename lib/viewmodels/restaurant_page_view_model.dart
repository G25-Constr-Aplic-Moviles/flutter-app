import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import 'package:test3/services/restaurant_api_service.dart';

class FoodViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Food> menu = [];

  Future<void> loadMenu(int restaurantId) async {
    try {
      menu = await _apiService.fetchFoods(restaurantId);
    } catch (e) {
      print('Error fetching menu: $e');
    } finally {
      notifyListeners();
    }
  }
}

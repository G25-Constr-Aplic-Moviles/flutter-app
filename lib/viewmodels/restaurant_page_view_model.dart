import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import 'package:test3/services/restaurant_api_service.dart';

class FoodViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Food> menu = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadMenu(int restaurantId) async {
    _isLoading = true;
    notifyListeners(); // Notificamos que estamos cargando

    try {
      menu = await _apiService.fetchFoods(restaurantId);
    } catch (e) {
      print('Error fetching menu: $e');
    } finally {
      _isLoading = false;
      // Usar addPostFrameCallback para evitar el error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}

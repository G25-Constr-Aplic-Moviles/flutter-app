import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import '../services/api_service.dart';

class MenuItemViewModel extends ChangeNotifier {
  List<Food> _foodMenu = [];
  final ApiService _apiService = ApiService();

  List<Food> get foodMenu => _foodMenu;

  Future<void> fetchMenu(int idRestaurant) async {
    try {
      List<dynamic> data = await _apiService.fetchMenu(idRestaurant);
      _foodMenu = data.map((item) => Food.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching menu: $e');
    }
  }

  Future<Map<String, List<Food>>> fetchAllMenus() async {
    Map<String, List<Food>> restaurantMenus = {};
    try {
      List<dynamic> restaurants = await _apiService.fetchRestaurants();
      for (var restaurant in restaurants) {
        int restaurantId = restaurant['id'];
        String restaurantName = restaurant['name'];
        List<dynamic> menuData = await _apiService.fetchMenu(restaurantId);
        List<Food> menuItems = menuData.map((item) => Food.fromJson(item)).toList();
        restaurantMenus[restaurantName] = menuItems;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching all menus: $e');
    }
    return restaurantMenus;
  }
}

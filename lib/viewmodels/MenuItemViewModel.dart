import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import '../services/api_service.dart';

class MenuItemViewModel extends ChangeNotifier {
  List<Food> _foodMenu = [];
  List<Map<String, dynamic>> _allFoodMenu = [];
  final ApiService _apiService = ApiService();

  List<Food> get foodMenu => _foodMenu;
  List<Map<String, dynamic>> get allFoodMenu => _allFoodMenu;

  Future<void> fetchMenu(int idRestaurant) async {
    try {
      List<dynamic> data = await _apiService.fetchMenu(idRestaurant);
      _foodMenu = data.map((item) => Food.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching menu: $e');
    }
  }

  Future<void> fetchAllMenus() async {
    try {
      List<dynamic> restaurants = await _apiService.fetchRestaurants();
      List<Map<String, dynamic>> allMenuItems = [];
      for (var restaurant in restaurants) {
        int restaurantId = restaurant['restaurant_id'];
        String restaurantName = restaurant['name'];
        String restaurantAddress = restaurant['address'];
        List<dynamic> menuData = await _apiService.fetchMenu(restaurantId);
        List<Map<String, dynamic>> menuItems = menuData.map((item) {
          // Convertir el precio a double si es necesario
          if (item['price'] is int) {
            item['price'] = (item['price'] as int).toDouble();
          }
          return {
            'food': Food.fromJson(item),
            'restaurantName': restaurantName,
            'restaurantAddress': restaurantAddress,
          };
        }).toList();
        allMenuItems.addAll(menuItems);
      }
      _allFoodMenu = allMenuItems;
      notifyListeners();
    } catch (e) {
      print('Error fetching all menus: $e');
    }
  }
}

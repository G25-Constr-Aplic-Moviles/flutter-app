import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import '../services/api_service.dart';

class MenuItemViewModel extends ChangeNotifier {
  List<Food> _foodMenu = [];
  List<Map<String, dynamic>> _allFoodMenu = [];
  List<Map<String, dynamic>> _filteredFoodMenu = [];
  final ApiService _apiService = ApiService();

  List<Food> get foodMenu => _foodMenu;
  List<Map<String, dynamic>> get allFoodMenu => _allFoodMenu;
  List<Map<String, dynamic>> get filteredFoodMenu => _filteredFoodMenu;

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
      _filteredFoodMenu = List.from(_allFoodMenu);
      notifyListeners();
    } catch (e) {
      print('Error fetching all menus: $e');
    }
  }

  void filterByPrice(String filter) {
    if (filter == 'top_5_cheapest') {
      _filteredFoodMenu = List.from(_allFoodMenu)
        ..sort((a, b) => a['food'].price.compareTo(b['food'].price));
      if (_filteredFoodMenu.length > 5) {
        _filteredFoodMenu = _filteredFoodMenu.sublist(0, 5);
      }
    } else if (filter == 'top_5_expensive') {
      _filteredFoodMenu = List.from(_allFoodMenu)
        ..sort((a, b) => b['food'].price.compareTo(a['food'].price));
      if (_filteredFoodMenu.length > 5) {
        _filteredFoodMenu = _filteredFoodMenu.sublist(0, 5);
      }
    } else if (filter == 'less_than_10000') {
      _filteredFoodMenu = _allFoodMenu.where((item) => item['food'].price < 10000).toList();
    } else if (filter == 'between_10000_20000') {
      _filteredFoodMenu = _allFoodMenu.where((item) => item['food'].price >= 10000 && item['food'].price <= 20000).toList();
    } else if (filter == 'more_than_20000') {
      _filteredFoodMenu = _allFoodMenu.where((item) => item['food'].price > 20000).toList();
    } else if (filter == 'most_dishes') {
      Map<String, int> restaurantDishCount = {};
      for (var item in _allFoodMenu) {
        String restaurantName = item['restaurantName'];
        if (restaurantDishCount.containsKey(restaurantName)) {
          restaurantDishCount[restaurantName] = restaurantDishCount[restaurantName]! + 1;
        } else {
          restaurantDishCount[restaurantName] = 1;
        }
      }
      String restaurantWithMostDishes = restaurantDishCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      _filteredFoodMenu = _allFoodMenu.where((item) => item['restaurantName'] == restaurantWithMostDishes).toList();
    } else {
      _filteredFoodMenu = List.from(_allFoodMenu);
    }
    notifyListeners();
  }
}

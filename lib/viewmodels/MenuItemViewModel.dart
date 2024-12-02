import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MenuItemViewModel extends ChangeNotifier {
  List<Food> _foodMenu = [];
  List<Map<String, dynamic>> _allFoodMenu = [];
  List<Map<String, dynamic>> _filteredFoodMenu = [];
  final ApiService _apiService = ApiService();
  bool _isConnected = true;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Food> get foodMenu => _foodMenu;
  List<Map<String, dynamic>> get allFoodMenu => _allFoodMenu;
  List<Map<String, dynamic>> get filteredFoodMenu => _filteredFoodMenu;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  MenuItemViewModel() {
    _checkConnectivity();
    _loadCachedMenus();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _isConnected = true;
        fetchAllMenus();
      } else {
        _isConnected = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<void> fetchMenu(int idRestaurant) async {
    await _checkConnectivity();
    if (!_isConnected) {
      _errorMessage = 'No internet connection!';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<dynamic> data = await _apiService.fetchMenu(idRestaurant);
      _foodMenu = data.map((item) => Food.fromJson(item)).toList();
      _errorMessage = '';
      _cacheMenus();
    } catch (e) {
      _errorMessage = 'Error fetching menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllMenus() async {
    await _checkConnectivity();
    if (!_isConnected) {
      _errorMessage = 'No internet connection!';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<dynamic> restaurants = await _apiService.fetchRestaurants();
      List<Map<String, dynamic>> allMenuItems = [];
      for (var restaurant in restaurants) {
        int restaurantId = restaurant['restaurant_id'];
        String restaurantName = restaurant['name'];
        String restaurantAddress = restaurant['address'];
        List<dynamic> menuData = await _apiService.fetchMenu(restaurantId);
        List<Map<String, dynamic>> menuItems = menuData.map((item) {
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
      _errorMessage = '';
      _cacheMenus();
    } catch (e) {
      _errorMessage = 'Error fetching all menus: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> _cacheMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_allFoodMenu.map((item) {
      return {
        'food': item['food'].toMap(),
        'restaurantName': item['restaurantName'],
        'restaurantAddress': item['restaurantAddress'],
      };
    }).toList());
    await prefs.setString('cachedMenus', encodedData);
  }

  Future<void> _loadCachedMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cachedMenus');
    if (cachedData != null) {
      List<dynamic> data = jsonDecode(cachedData);
      _allFoodMenu = data.map((item) {
        return {
          'food': Food.fromMap(item['food']),
          'restaurantName': item['restaurantName'],
          'restaurantAddress': item['restaurantAddress'],
        };
      }).toList();
      _filteredFoodMenu = List.from(_allFoodMenu);
      notifyListeners();
    }
  }
}

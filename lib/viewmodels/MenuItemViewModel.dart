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
}
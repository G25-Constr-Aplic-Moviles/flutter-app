import 'package:flutter/material.dart';
import 'package:test3/models/food.dart';
import '../services/api_service.dart';

class MenuItemViewModel extends ChangeNotifier {
  List<Food> _foodMenu = [];
  int _likesDislikes = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  List<Food> get foodMenu => _foodMenu;
  int get likesDislikes => _likesDislikes;
  bool get isLoading => _isLoading;

  Future<void> fetchMenu(int idRestaurant) async {
    try {
      List<dynamic> data = await _apiService.fetchMenu(idRestaurant);
      _foodMenu = data.map((item) => Food.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching menu: $e');
    }
  }

  Future<void> fetchLikesDislikes(int idItem) async {
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _apiService.fetchLikesDislikes(idItem);

      _likesDislikes = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching likes/dislikes: $e');
    } 
  }

  Future<void> updateLikes(int idItem) async {
    try{
      await _apiService.updateLikes(idItem);
      fetchLikesDislikes(idItem);
      notifyListeners();
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  Future<void> updateDislikes(int idItem) async {
    try{
      await _apiService.updateDislikes(idItem);
      fetchLikesDislikes(idItem);
      notifyListeners();
    } catch (e) {
      print('Error updating likes: $e');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:test3/services/history_service.dart';

class RestaurantPageViewModel extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<int> markRestaurantVisited(int idRestaurant) async {
    _isLoading = true;
    notifyListeners();

    int response = await _historyService.markRestaurantVisited(idRestaurant);

    _isLoading = false;
    notifyListeners();

    return response;
  }
}


import 'package:flutter/material.dart';
import 'package:test3/services/history_service.dart';
import 'package:test3/viewmodels/restaurants_list_viewmodel.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  final RestaurantsListViewModel _restaurantsViewModel = RestaurantsListViewModel();

  List _history = [];
  List _restaurants = [];
  bool _isLoading = true;

  List get history => _history;
  List get restaurants => _restaurants;
  bool get isLoading => _isLoading;

  HistoryViewModel() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    _history = await _historyService.fetchHistory();

    await _restaurantsViewModel.fetchRestaurants();
    _restaurants = _restaurantsViewModel.restaurants;

    _isLoading = false;
    notifyListeners();
  }
}

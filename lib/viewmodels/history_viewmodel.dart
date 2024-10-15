import 'package:flutter/material.dart';
import 'package:test3/models/history_entry.dart';
import 'package:test3/models/token_manager.dart';
import 'package:test3/services/api_service.dart';
import 'package:test3/services/history_service.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryService historyService;
  final ApiService apiService;
  List<HistoryEntry> _history = [];

  bool isLoading = false;
  String errorMessage = '';

  HistoryViewModel({required this.historyService, required this.apiService});

  List<HistoryEntry> get history => _history;

  Future<void> getHistory(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      isLoading = false;
      errorMessage = 'No internet connection!';
      notifyListeners();
      return;
    }

    try {
      final historyList = await historyService.fetchHistory().timeout(const Duration(seconds: 5));
      List<HistoryEntry> updatedHistory = [];

      for (var entry in historyList) {
        final restaurant = await apiService.fetchRestaurant(entry['restaurant_id']);
        if (restaurant != null) {
          updatedHistory.add(HistoryEntry(
            restaurantName: restaurant.name,
            date: entry['date'],
          ));
        }
      }

      _history = updatedHistory;
      isLoading = false;
      errorMessage = '';
    } on TimeoutException catch (_) {
      isLoading = false;
      errorMessage = 'Request timed out. Please try again.';
    } catch (e) {
      isLoading = false;
      errorMessage = 'Server Error. Retry!';
    }

    notifyListeners();
  }
}

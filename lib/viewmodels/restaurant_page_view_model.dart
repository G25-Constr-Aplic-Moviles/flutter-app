import 'package:flutter/material.dart';
import 'package:test3/services/history_service.dart';

class RestaurantPageViewModel extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> markRestaurantVisited(int idRestaurant, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    bool isConnected = await _historyService.isConnectedToInternet();
    if (!isConnected) {
      _isLoading = false;
      notifyListeners();
      _showSnackBar(context, "Tu dispositivo no esta conectado a Internet");  
    }

    int response = await _historyService.markRestaurantVisited(idRestaurant);
    _isLoading = false;
    notifyListeners();

    if (response != 200) {
      _showSnackBar(context, "Error al marcar el restaurante como visitado.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}


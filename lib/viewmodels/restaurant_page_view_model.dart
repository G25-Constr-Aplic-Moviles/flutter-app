import 'package:flutter/material.dart';
import 'package:test3/services/history_service.dart';

class RestaurantPageViewModel extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  bool _isLoading = true;

  List<int> _pendingRestaurants = [];
  bool get hasPendingVisits => _pendingRestaurants.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> markRestaurantVisited(int idRestaurant, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    bool isConnected = await _historyService.isConnectedToInternet();
    if (!isConnected) {
      _isLoading = false;
      _pendingRestaurants.add(idRestaurant);
      notifyListeners();
      _showSnackBar(context, "Sin conexion. La visita sera marcada cuando te reconectes.", Colors.black);
      return;  
    }

    await _processRestaurantVisit(idRestaurant, context);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> retryPendingVisits(BuildContext context) async {
    if (_pendingRestaurants.isEmpty) return;
    bool isConnected = await _historyService.isConnectedToInternet();
    if (!isConnected) return;

    List<int> pending = List.from(_pendingRestaurants);

    for (int id in pending) {
      bool success = await _processRestaurantVisit(id, context);
      if (success) {
        _pendingRestaurants.remove(id); // Elimina el ID de la lista si fue procesado
      }
    }
  }

  Future<bool> _processRestaurantVisit(int idRestaurant, BuildContext context) async {
    try {
      int response = await _historyService.markRestaurantVisited(idRestaurant);
      if (response == 200) {
        _showSnackBar(context, "Se marco la visita correctamente.", Colors.green);
        return true;
      } else {
        _showSnackBar(context, "Error al marcar la visita.", Colors.black);
        return false;
      }
    } catch (e) {
      print("Error procesando visita: $e");
      return false;
    }
  }
}

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      ),
  );
}



import 'package:flutter/material.dart';
import 'package:test3/services/api_service.dart';
import 'package:test3/models/restaurant_model.dart';

class DiscountRestaurantsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Restaurant> _restaurantsWithDiscount = [];
  List<Restaurant> get restaurantsWithDiscount => _restaurantsWithDiscount;

  // Método para obtener los restaurantes con un descuento específico
  Future<void> fetchRestaurantsWithDiscount(String discountType) async {
    try {
      // Llamada al servicio de API para obtener los restaurantes con el descuento
      final List response = await _apiService.fetchRestaurantsWithDiscount(discountType);

      // Convertimos la respuesta en una lista de objetos Restaurant
      _restaurantsWithDiscount = response.map((e) => Restaurant.fromJson(e)).toList();

      // Notificamos a los escuchadores de cambios
      notifyListeners();
    } catch (error) {
      print('Error fetching discounted restaurants: $error');
      throw Exception('Failed to load discounted restaurants');
    }
  }
}

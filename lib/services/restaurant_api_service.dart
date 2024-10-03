import 'package:http/http.dart' as http;
import 'package:test3/models/food.dart';
import 'dart:convert';

import 'package:test3/models/restaurant.dart';

class ApiService {

  // Función para obtener los restaurantes
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('https://restaurantservice-375afbe356dc.herokuapp.com/restaurant/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  // Funcion para obtener los menu items de un restaurante especifico
  Future<List<Food>> fetchFoods(int restaurantId) async {
    final response = await http.get(Uri.parse('https://restaurantservice-375afbe356dc.herokuapp.com/menu_item/$restaurantId'));

    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

}
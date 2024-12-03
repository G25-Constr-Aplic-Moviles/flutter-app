import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant_model.dart';

class DiscountedRestaurantsViewModel extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRestaurants(String discount) async {
    final String cacheKey = 'restaurants_$discount';
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch data from network
      final response = await http.get(Uri.parse(
          'https://restaurantservice-375afbe356dc.herokuapp.com/restaurant/discounts/$discount'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        _restaurants = jsonData.map((data) => Restaurant.fromJson(data)).toList();

        // Cache the data
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(cacheKey, jsonEncode(jsonData));
      } else {
        throw Exception('Failed to load restaurants from network');
      }
    } catch (e) {
      // Fallback to cache
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonData = jsonDecode(cachedData);
        _restaurants = jsonData.map((data) => Restaurant.fromJson(data)).toList();
      } else {
        _restaurants = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

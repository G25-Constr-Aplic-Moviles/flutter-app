import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test3/models/restaurant_model.dart';
import 'package:test3/repositories/restaurant_repository.dart';


class ApiService extends RestaurantRepository{
  final String? _baseUrl = dotenv.env['RESTAURANT_API_URL'];
  final String? _baseUrl_recommendation = dotenv.env['RECOMMENDATION_SERVICE_URL'];
  final String? _baseUrl_likes_dislikes = dotenv.env['LIKES_DISLIKES_SERVICE_URL'];

  @override
  Future<void> updateLikes(int itemId) async {
    final response = await http.patch(Uri.parse('$_baseUrl_likes_dislikes/likes/$itemId/increment'));
    if(response.statusCode == 200){
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception('Error: Success flag is false');
      } 
    } else {
      throw Exception('Failed to update likes: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateDislikes(int itemId) async {
    final response = await http.patch(Uri.parse('$_baseUrl_likes_dislikes/dislikes/$itemId/increment'));
    if(response.statusCode == 200){
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception('Error: Success flag is false');
      }
    } else {
      throw Exception('Failed to update dislikes: ${response.statusCode}');
    }
  }

  @override
  Future<int> fetchLikesDislikes(int itemId) async {
    final response = await http.get(Uri.parse('$_baseUrl_likes_dislikes/likes_dislikes/$itemId'));
    if(response.statusCode == 200) {

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['data'][0];
      } else {
        throw Exception('Error: Success flag is false');
      }
    }
    else{
      throw Exception('Failed to load likes/dislikes: ${response.statusCode}');
    }
  }
 
  @override
  Future<List> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$_baseUrl/restaurant/list'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }
  }

  @override
  Future<List> fetchRecommendedRestaurants(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrl_recommendation/recommend/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }
  }

  @override
  Future<List> fetchMenu(int idRestaurant) async {
    final response = await http.get(Uri.parse('$_baseUrl/menu_item/$idRestaurant'));
    if(response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu: ${response.statusCode}'); 
    }
  }

  @override
  Future<Map> fetchRoute(
      double originLat, double originLng, double destLat, double destLng, String apiKey) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destLat,$destLng&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }

  Future<Restaurant?> fetchRestaurant(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/restaurant/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Restaurant.fromJson(data);
    } else {
      return null;
    }
  }
  @override
  Future<List> fetchRestaurantsWithDiscount(String discountType) async {
    final response = await http.get(Uri.parse('$_baseUrl/restaurant/discounts/$discountType'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load discounted restaurants: ${response.statusCode}');
    }
  }

}



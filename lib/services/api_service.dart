import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String? _baseUrl = dotenv.env['RESTAURANT_API_URL'];

  Future<List<dynamic>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$_baseUrl/restaurant/list'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchRoute(
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
}

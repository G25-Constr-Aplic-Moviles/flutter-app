import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test3/models/token_manager.dart';
import 'dart:convert';
import 'package:test3/repositories/history_repository.dart';

class HistoryService implements HistoryRepository {
  final String? _baseUrl = dotenv.env['HISTORY_API_URL'];
  final TokenManager _tokenManager = TokenManager();

  static final HistoryService _instance = HistoryService._internal();

  factory HistoryService() {
    return _instance;
  }

  HistoryService._internal();

  @override
  Future<int> markRestaurantVisited(int idRestaurant) async {
    String? userId = await _tokenManager.userId;
    final response = await http.post(
      Uri.parse('$_baseUrl/history/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "restaurant_id": idRestaurant
      }));
    
    return response.statusCode;
  }

  @override
  Future<List> fetchHistory() async {
    String? userId = await _tokenManager.userId;
    final response = await http.get(
      Uri.parse('$_baseUrl/history/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
}

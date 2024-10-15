import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test3/models/token_manager.dart';
import 'dart:convert';
import 'package:test3/repositories/history_repository.dart';

class HistoryService implements HistoryRepository {
  static final HistoryService _instance = HistoryService._internal();

  factory HistoryService() {
    return _instance;
  }

  HistoryService._internal();

  @override
  Future<List> fetchHistory() async {
    final response = await http.get(
      Uri.parse('http://localhost:5001/history/7f0b6fa2-fbd3-4602-acb0-5cd319c1d2bc'),
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

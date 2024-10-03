import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test3/pages/restaurants_list.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final response = await http.post(
      Uri.parse(dotenv.env['USERS_API_URL']!+'/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    isLoading = false;

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RestaurantsListPage()),
      );
      notifyListeners();
    } else {
      errorMessage = 'Failed to login';
      notifyListeners();
    }
  }
}

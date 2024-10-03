import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test3/pages/restaurants_list.dart';
 // Asegúrate de tener este archivo en tu proyecto

class RegisterViewModel extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> register(BuildContext context) async {
    final apiUrl = dotenv.env['USERS_API_URL'];
    if (apiUrl == null) {
      errorMessage = 'API URL is not set';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final response = await http.post(
      Uri.parse('$apiUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstName': firstName,
        'lastName': lastName,
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
      errorMessage = 'Failed to register';
      notifyListeners();
    }
  }
}

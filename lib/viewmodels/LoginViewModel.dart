import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/token_manager.dart';
import '../pages/restaurants_list.dart';

class LoginViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      isLoading = false;
      errorMessage = 'No internet connection!';
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['USERS_API_URL']!}/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      isLoading = false;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        TokenManager().setToken(responseBody['token']);
        TokenManager().setUserId(responseBody['id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
        );
        notifyListeners();
      } else {
        errorMessage = 'Wrong Email/Password!';
        notifyListeners();
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      errorMessage = 'Server Timeout!';
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred: $e';
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/services/user_service.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginViewModel extends ChangeNotifier {
  final UserService userService;

  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  LoginViewModel({required this.userService});

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
      final isAuthenticated = await userService.authenticate(email, password).timeout(const Duration(seconds: 2));

      isLoading = false;

      if (isAuthenticated==true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
        );
      } else {
        errorMessage = 'Wrong Email/Password!';
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      errorMessage = 'Request timed out. Please try again.';
    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }
}

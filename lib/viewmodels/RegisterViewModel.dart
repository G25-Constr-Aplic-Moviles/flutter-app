import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/services/user_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserService userService;

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  RegisterViewModel({required this.userService});

  Future<void> register(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final isRegistered = await userService.register(firstName, lastName, email, password).timeout(const Duration(seconds: 2));

      isLoading = false;

      if (isRegistered == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
        );
      } else {
        errorMessage = 'Failed! Try another email';
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      errorMessage = 'server timeout!';
    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred!';
    }

    notifyListeners();
  }
}

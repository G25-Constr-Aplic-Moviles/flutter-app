import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:test3/pages/restaurants_list.dart';
import 'package:test3/services/user_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final UserService userService;

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  RegisterViewModel({required this.userService});

  Future<void> register(BuildContext context) async {
    // Check internet connection first
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorDialog(context, 'No internet connection');
      return;
    }

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'There are empty fields! All items are required.');
      return;
    }

    if (!isValidEmail(email)) {
      _showErrorDialog(context, 'Please enter a valid email.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final isRegistered = await userService
          .register(firstName, lastName, email, password)
          .timeout(const Duration(seconds: 2));

      isLoading = false;

      if (isRegistered == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
        );
      } else {
        _showErrorDialog(context, 'Register Failed! Try another email.');
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      _showErrorDialog(context, 'Server timeout!');
    } catch (e) {
      isLoading = false;
      _showErrorDialog(context, 'No internet connection');
    }

    notifyListeners();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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

  LoginViewModel({required this.userService});

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      isLoading = false;
      _showErrorDialog(context, 'No internet connection!');
      return;
    }

    try {
      final isAuthenticated = await userService.authenticate(email, password).timeout(const Duration(seconds: 4));
      isLoading = false;

      if (isAuthenticated == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantsListPage()),
        );
      } else {
        _showErrorDialog(context, 'Wrong Email/Password!');
      }
    } on TimeoutException catch (_) {
      isLoading = false;
      _showErrorDialog(context, 'Request timed out. Please try again.');
    } catch (e) {
      isLoading = false;
      _showErrorDialog(context, 'Server Error. Retry!');
    }

    clear();
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

  void clear() {
    email = '';
    password = '';
    notifyListeners();
  }
}

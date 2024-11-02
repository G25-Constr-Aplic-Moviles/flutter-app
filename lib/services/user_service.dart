import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test3/models/token_manager.dart';
import 'dart:convert';

import 'package:test3/repositories/user_repository.dart';

class UserService implements UserRepository {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  @override
  Future<bool?> authenticate(String email, String password) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['USERS_API_URL']!}/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      TokenManager().setToken(responseBody['token']);
      TokenManager().setUserId(responseBody['id']);
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse(dotenv.env['USERS_API_URL']!),
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

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      TokenManager().setToken(responseBody['token']);
      TokenManager().setUserId(responseBody['id']);
      return true;
    } else {
      return false;
    }
  }
}

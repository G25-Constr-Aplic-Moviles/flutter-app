import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  static TokenManager get instance => _instance;

  Future<String?> get token async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> get userId async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<DateTime?> get expireAt async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expireAtString = prefs.getString('expireAt');
    if (expireAtString != null) {
      return DateTime.parse(expireAtString);
    }
    return null;
  }

  Future<void> setToken(String token, String userId, String expireAt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('expireAt', expireAt);
  }

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('expireAt');
  }
}

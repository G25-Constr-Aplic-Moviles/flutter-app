class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  String? _token;
  String? _userId;

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  static TokenManager get instance => _instance;

  String? get token => _token;
  String? get userId => _userId;

  void setToken(String token) {
    _token = token;
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  void clear() {
    _token = null;
    _userId = null;
  }
}
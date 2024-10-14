import 'package:test3/models/user.dart';

abstract class UserRepository {
  Future<bool?> authenticate(String username, String password);
}

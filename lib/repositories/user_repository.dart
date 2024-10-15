abstract class UserRepository {
  Future<bool?> authenticate(String username, String password);
  Future<bool?> register(String firstName, String lastName, String email, String password);
}

abstract class AuthRepo {
  Future<String> register(
      String fullName, String email, String password, String role);

  Future<String> login(String email, String password);

  Future<void> logout();
}
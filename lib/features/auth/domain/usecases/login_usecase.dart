import '../repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepo _repo;
  LoginUseCase(this._repo);

  Future<String> call(String email, String password) =>
      _repo.login(email, password);
}
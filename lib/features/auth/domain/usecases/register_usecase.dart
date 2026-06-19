import '../repositories/auth_repo.dart';

class RegisterUseCase {
  final AuthRepo _repo;
  RegisterUseCase(this._repo);

    Future<String> call(
      String fullName,
      String email,
      String password,
      String role,
      ) => _repo.register(fullName, email, password, role);
}
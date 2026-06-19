import '../../domain/repositories/auth_repo.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _remote;
  AuthRepoImpl(this._remote);

  @override
  Future<String> register(
      String fullName, String email, String password, String role) =>
      _remote.register(fullName, email, password, role);

  @override
  Future<String> login(String email, String password) =>
      _remote.login(email, password);

  @override
  Future<void> logout() => _remote.logout();
}
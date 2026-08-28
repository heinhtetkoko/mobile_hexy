import 'package:mobile_hexy/data/models/auth_session.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String username,
    required String email,
    required String password,
  }) =>
      _repository.signup(username: username, email: email, password: password);
}

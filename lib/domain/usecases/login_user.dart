import 'package:mobile_hexy/data/models/auth_session.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String login, required String password}) =>
      _repository.login(login: login, password: password);
}

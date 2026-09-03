import 'package:mobile_hexy/data/models/auth_session.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call(String idToken) =>
      _repository.loginWithGoogle(idToken);
}

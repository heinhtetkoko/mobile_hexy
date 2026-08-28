import 'package:mobile_hexy/domain/repositories/auth_repository.dart';

class LogoutUser {
  const LogoutUser(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

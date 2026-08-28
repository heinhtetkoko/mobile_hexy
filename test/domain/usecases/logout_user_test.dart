import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/auth_session.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';

void main() {
  test('logout delegates session removal to the auth repository', () async {
    final repository = _FakeAuthRepository();

    await LogoutUser(repository)();

    expect(repository.didLogout, isTrue);
  });
}

class _FakeAuthRepository implements AuthRepository {
  bool didLogout = false;

  @override
  Future<void> logout() async => didLogout = true;

  @override
  Future<AuthSession> login({
    required String login,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthSession> signup({
    required String username,
    required String email,
    required String password,
  }) => throw UnimplementedError();
}

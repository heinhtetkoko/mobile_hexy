import 'package:mobile_hexy/data/models/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String login, required String password});

  Future<AuthSession> signup({
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();
}

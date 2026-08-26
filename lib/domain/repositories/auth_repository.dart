import 'package:mobile_hexy/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String login, required String password});
}

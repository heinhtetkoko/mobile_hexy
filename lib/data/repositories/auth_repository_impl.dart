import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';
import 'package:mobile_hexy/data/models/auth_session.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  @override
  Future<AuthSession> login({
    required String login,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      login: login,
      password: password,
    );
    await _secureStorage.write(
      AppConstants.accessTokenKey,
      session.accessToken,
    );
    return session;
  }

  @override
  Future<AuthSession> loginWithGoogle(String idToken) async {
    final session = await _remoteDataSource.loginWithGoogle(idToken);
    await _secureStorage.write(
      AppConstants.accessTokenKey,
      session.accessToken,
    );
    return session;
  }

  @override
  Future<AuthSession> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.signup(
      username: username,
      email: email,
      password: password,
    );
    await _secureStorage.write(
      AppConstants.accessTokenKey,
      session.accessToken,
    );
    return session;
  }

  @override
  Future<void> logout() => _secureStorage.remove(AppConstants.accessTokenKey);
}

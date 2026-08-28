import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/data/models/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.accessToken});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedToken = data is Map<String, dynamic>
        ? data['access_token']
        : null;
    final token = nestedToken ?? json['access_token'];

    if (token is! String || token.isEmpty) {
      throw const ServerException(
        'The authentication response did not contain a token.',
      );
    }
    return AuthSessionModel(accessToken: token);
  }
}
